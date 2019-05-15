defmodule LassoWeb.LassoController do
  use LassoWeb, :controller

  def show(conn, %{"uuid" => uuid}) do
    url = "http://localhost:4000/hooks/#{uuid}"
    render(conn, "lasso.html", url: url, uuid: uuid)
  end

  def new(conn, _params) do
    uuid = UUID.uuid4()
    url = "http://localhost:4000/hooks/#{uuid}"
    with :ok <- Lasso.Hook.create(uuid) do
      render(conn, "lasso.html", url: url, uuid: uuid)
    end
  end
end
