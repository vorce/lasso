defmodule LassoWeb.HookController do
  use LassoWeb, :controller

  def request(conn, %{"uuid" => uuid}) do
    request = %Lasso.Request{
      timestamp: DateTime.utc_now(),
      method: conn.method,
      query_params: conn.query_params,
      headers: Enum.into(conn.req_headers, %{}),
      request_path: conn.request_path,
      ip: formatted_ip(conn.remote_ip),
      body: conn.private[:raw_body] || ""
    }

    with {:ok, _value} <- Lasso.Hook.get(uuid),
         :ok <- Lasso.Hook.add(uuid, request) do
      render(conn, "request.json", uuid: uuid)
    else
      {:error, :no_such_key, _} ->
        resp(conn, 404, "")
    end
  end

  defp formatted_ip({a, b, c, d}) do
    "#{a}.#{b}.#{c}.#{d}"
  end

  defp formatted_ip(other), do: inspect(other)
end
