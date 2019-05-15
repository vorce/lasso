defmodule LassoWeb.LassoController do
  use LassoWeb, :controller
  import Phoenix.LiveView.Controller

  def show(conn, %{"uuid" => uuid} = params) do
    url = "http://localhost:4000/hooks/#{uuid}"

    with {:ok, requests} <- Lasso.Hook.get(uuid) do
      live_render(conn, LassoWeb.LassoLiveView,
        session: %{url: url, uuid: uuid, requests: requests}
      )
    else
      {:error, :no_such_key, _} ->
        conn
        |> resp(404, "")
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
