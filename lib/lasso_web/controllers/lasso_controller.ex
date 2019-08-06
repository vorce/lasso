defmodule LassoWeb.LassoController do
  use LassoWeb, :controller
  require Logger

  def request(conn, %{"uuid" => uuid}) do
    request = Lasso.Request.from(conn)

    with {:ok, _value} <- Lasso.get(uuid),
         :ok <- Lasso.add(uuid, request) do
      render(conn, "request.json", uuid: uuid)
    else
      {:error, :no_such_key, _} ->
        resp(conn, 410, "No such lasso")
    end
  end
end
