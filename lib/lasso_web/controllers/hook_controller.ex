defmodule LassoWeb.HookController do
  use LassoWeb, :controller

  def request(conn, %{"uuid" => uuid} = params) do
    body = conn |> Plug.Conn.read_body() |> read_full_body([])

    request = %Lasso.Request{
      timestamp: DateTime.utc_now(),
      method: conn.method,
      query_params: conn.query_params,
      headers: conn.req_headers,
      request_path: conn.request_path,
      ip: conn.remote_ip,
      body: body
    }

    with {:ok, _value} <- Lasso.Hook.get(uuid),
         :ok <- Lasso.Hook.add(uuid, request) do
      render(conn, "get.json", uuid: uuid)
    else
      {:error, :no_such_key, _} ->
        resp(conn, 404, "")
    end
  end

  # TODO only allow bodies of certain size?
  defp read_full_body({:ok, body, conn}, acc) do
    Enum.reverse([body | acc])
  end

  defp read_full_body({:more, partial_body, conn}, acc) do
    read_full_body(Plug.Conn.read_body(conn), [partial_body | acc])
  end

  def post(conn, params) do
    conn
  end

  def put(conn, params) do
    conn
  end

  def delete(conn, params) do
    conn
  end

  def patch(conn, params) do
    conn
  end
end
