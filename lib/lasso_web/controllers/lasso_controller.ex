defmodule LassoWeb.LassoController do
  use LassoWeb, :controller
  alias Phoenix.LiveView.Controller

  def show(conn, %{"uuid" => uuid}) do
    path = LassoWeb.Router.Helpers.hook_path(LassoWeb.Endpoint, :request, uuid)
    url = url(conn, path)

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

    with :ok <- Lasso.Hook.create(uuid) do
      redirect(conn, to: "/lasso/#{uuid}")
    end
  end

  defp url(conn, path) do
    "#{conn.scheme}://#{conn.host}#{port_str(conn)}#{path}"
  end

  defp port_str(%Plug.Conn{scheme: :https, port: port}) when port in [80, 443], do: ""
  defp port_str(%Plug.Conn{scheme: :http, port: 80}), do: ""
  defp port_str(%Plug.Conn{port: port}), do: ":#{port}"
end
