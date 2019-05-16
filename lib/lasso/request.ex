defmodule Lasso.Request do
  require Logger

  defstruct headers: [],
            method: "",
            body: "",
            query_params: %{},
            request_path: "",
            timestamp: DateTime.utc_now(),
            ip: ""

  def from(%Plug.Conn{} = conn) do
    %Lasso.Request{
      timestamp: DateTime.utc_now(),
      method: conn.method,
      query_params: conn.query_params,
      headers: Enum.into(conn.req_headers, %{}),
      request_path: conn.request_path,
      ip: formatted_ip(conn.remote_ip, Plug.Conn.get_req_header(conn, "x-forwarded-for")),
      body: conn.private[:raw_body] || ""
    }
  end

  defp formatted_ip({a, b, c, d}, _) do
    "#{a}.#{b}.#{c}.#{d}"
  end

  defp formatted_ip(ip, []) do
    inspect(ip)
  end

  defp formatted_ip(_ip, forwarded_for) when is_list(forwarded_for) do
    forwarded_for
    |> Enum.reverse()
    |> List.first()
  end
end
