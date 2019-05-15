defmodule LassoWeb.LassoController do
  use LassoWeb, :controller
  import Phoenix.LiveView.Controller

  def show(conn, %{"uuid" => uuid} = params) do
    url = "http://localhost:4000/hooks/#{uuid}"

    live_render(conn, LassoWeb.LassoLiveView, session: %{url: url, uuid: uuid})
  end

  def new(conn, _params) do
    uuid = UUID.uuid4()
    url = "http://localhost:4000/hooks/#{uuid}"

    with :ok <- Lasso.Hook.create(uuid) do
      live_render(conn, LassoWeb.LassoLiveView, session: %{url: url, uuid: uuid})
    end
  end
end
