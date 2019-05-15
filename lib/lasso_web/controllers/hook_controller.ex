defmodule LassoWeb.HookController do
  use LassoWeb, :controller

  def get(conn, %{"uuid" => uuid} = params) do
    with {:ok, _value} <- Lasso.Hook.get(uuid),
         :ok <- Lasso.Hook.add(uuid, conn, params) do
      render(conn, "get.json", uuid: uuid)
    else
      {:error, :no_such_key, _} ->
        conn
        |> resp(404, "")
    end
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
