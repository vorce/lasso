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
      ip: formatted_ip(conn.remote_ip),
      body: conn.private[:raw_body] || ""
    }
  end

  defp formatted_ip(ip) when is_tuple(ip) do
    ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp formatted_ip(other) do
    Logger.info("Got unexpected ip format: #{inspect(other)}")
    inspect(other)
  end
end
