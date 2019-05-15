defmodule LassoWeb.LassoController do
  use LassoWeb, :controller
  alias Phoenix.LiveView.Controller

  def show(conn, %{"uuid" => uuid}) do
    url = "http://localhost:4000/hooks/#{uuid}"

    with {:ok, requests} <- Lasso.Hook.get(uuid) do
      Controller.live_render(conn, LassoWeb.LassoLiveView,
        session: %{url: url, uuid: uuid, requests: requests}
      )
    else
      {:error, :no_such_key, _} ->
        render(conn, "404.html")
    end
  end

  def new(conn, _params) do
    uuid = UUID.uuid4()
    url = "http://localhost:4000/hooks/#{uuid}"

    with :ok <- Lasso.Hook.create(uuid) do
      redirect(conn, to: "/lasso/#{uuid}")
      # live_render(conn, LassoWeb.LassoLiveView, session: %{url: url, uuid: uuid, requests: []})
    end
  end
end
