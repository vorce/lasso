defmodule Lasso.Request do
  require Logger

  @ip_header "x-original-forwarded-for"

  defstruct headers: [],
            method: "",
            body: "",
            query_params: %{},
            request_path: "",
            timestamp: DateTime.utc_now(),
            ip: "",
            badge_class: ""

  def from(%Plug.Conn{} = conn) do
    %Lasso.Request{
      timestamp: DateTime.utc_now(),
      method: conn.method,
      query_params: conn.query_params,
      headers: Enum.into(conn.req_headers, %{}),
      request_path: conn.request_path,
      ip: formatted_ip(conn.remote_ip, Plug.Conn.get_req_header(conn, @ip_header)),
      body: conn.private[:raw_body] || "",
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

  # TODO re-consider this IP stuff. Maybe worth to use https://github.com/ajvondrak/remote_ip
  # or something?

  defp formatted_ip({a, b, c, d}, []) do
    "#{a}.#{b}.#{c}.#{d}"
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
