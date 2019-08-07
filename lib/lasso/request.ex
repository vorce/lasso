defmodule Lasso.Request do
  @moduledoc """
  Represents an incoming request to a lasso
  """

  alias Plug.Conn
  require Logger

  @ip_header "x-original-forwarded-for"
  @content_type "content-type"

  defstruct headers: [],
            method: "",
            body: "",
            query_params: %{},
            request_path: "",
            timestamp: DateTime.utc_now(),
            ip: "",
            badge_class: ""

  def from(%Conn{} = conn) do
    %Lasso.Request{
      timestamp: DateTime.utc_now(),
      method: conn.method,
      query_params: conn.query_params,
      headers: Enum.into(conn.req_headers, %{}),
      request_path: conn.request_path,
      ip: formatted_ip(conn.remote_ip, Conn.get_req_header(conn, @ip_header)),
      body: formatted_body(conn.private[:raw_body], Conn.get_req_header(conn, @content_type)),
      badge_class: badge_classes(conn.method)
    }
  end

  # Not sure about this one... should move into template or something.
  def badge_classes(), do: "badge float-right"
  def badge_classes("GET"), do: badge_classes() <> " badge-primary"
  def badge_classes("POST"), do: badge_classes() <> " badge-success"
  def badge_classes("PUT"), do: badge_classes() <> " badge-warning"
  def badge_classes("DELETE"), do: badge_classes() <> " badge-danger"
  def badge_classes("PATCH"), do: badge_classes() <> " badge-info"
  def badge_classes("OPTIONS"), do: badge_classes() <> " badge-dark"
  def badge_classes(_), do: badge_classes() <> " badge-secondary"

  defp formatted_body(nil, _), do: ""

  defp formatted_body(body, [content_type]) when is_binary(body) do
    case String.contains?(content_type, "application/json") do
      true ->
        pretty_json(body)

      false ->
        body
    end
  end

  defp formatted_body(body, _), do: body

  defp pretty_json(body) when is_binary(body) do
    with {:ok, struct} <- Jason.decode(body),
         {:ok, pretty} <- Jason.encode(struct, pretty: true) do
      pretty
    else
      _other -> body
    end
  end

  # Reconsider this IP stuff. Maybe worth to use https://github.com/ajvondrak/remote_ip
  # or something?

  defp formatted_ip(ip, []) when is_tuple(ip) do
    :inet.ntoa({0, 0, 0, 0, 0, 0, 0, 1})
  end

  defp formatted_ip(ip, []) do
    inspect(ip)
  end

  defp formatted_ip(conn_ip, [ips]) do
    ips
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> ip_from_header(conn_ip)
  end

  defp ip_from_header([], conn_ip), do: formatted_ip(conn_ip, [])
  defp ip_from_header([_single], conn_ip), do: formatted_ip(conn_ip, [])

  defp ip_from_header([_first | _rest] = ips, _conn_ip) do
    ips
    |> Enum.reverse()
    |> Enum.drop(1)
    |> Enum.take(1)
    |> List.first()
  end
end
