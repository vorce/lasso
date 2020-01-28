defmodule LassoWeb.LassoViewController do
  use LassoWeb, :controller
  alias Phoenix.LiveView.Controller

  def show(conn, %{"uuid" => uuid}) do
    path = LassoWeb.Router.Helpers.lasso_path(LassoWeb.Endpoint, :request, uuid)
    url = url(conn, path)

    case Lasso.get(uuid) do
      {:ok, requests} ->
        Controller.live_render(
          conn,
          LassoWeb.LassoLiveView,
          session: %{"url" => url, "uuid" => uuid, "requests" => requests}
        )

      {:error, :no_such_key, _} ->
        render(conn, "404.html")
    end
  end

  def new(conn, _params) do
    uuid = UUID.uuid4()

    with :ok <- Lasso.create(uuid) do
      redirect(conn, to: "/lasso/#{uuid}/view")
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    with :ok <- Lasso.delete(uuid) do
      conn
      |> put_flash(:info, "Successfully deleted lasso: #{uuid}")
      |> redirect(to: "/")
    end
  end

  defp url(conn, path) do
    "#{conn.scheme}://#{conn.host}#{port_str(conn)}#{path}"
  end

  defp port_str(%Plug.Conn{scheme: :https, port: port}) when port in [80, 443], do: ""
  defp port_str(%Plug.Conn{scheme: :http, port: 80}), do: ""
  defp port_str(%Plug.Conn{port: port}), do: ":#{port}"
end
