defmodule LassoWeb.HookController do
  use LassoWeb, :controller

  def request(conn, %{"uuid" => uuid}) do
    request = %Lasso.Request{
      timestamp: DateTime.utc_now(),
      method: conn.method,
      query_params: Jason.encode!(conn.query_params, pretty: true),
      headers: conn.req_headers,
      request_path: conn.request_path,
      ip: conn.remote_ip,
      body: conn.private.raw_body
    }

    with {:ok, _value} <- Lasso.Hook.get(uuid),
         :ok <- Lasso.Hook.add(uuid, request) do
      render(conn, "request.json", uuid: uuid)
    else
      {:error, :no_such_key, _} ->
        resp(conn, 404, "")
    end
  end
end
