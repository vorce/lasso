defmodule LassoWeb.LassoLiveView do
  use Phoenix.LiveView

  require Logger

  @request_limit Application.compile_env(:lasso, [Lasso, :max_requests_per_lasso])

  def render(assigns) do
    LassoWeb.LassoViewView.render("lasso.html", assigns)
  end

  def mount(_params, session, socket) do
    uuid = Map.fetch!(session, "uuid")
    Lasso.subscribe(uuid)

    assigns = [
      requests: Map.fetch!(session, "requests"),
      url: Map.fetch!(session, "url"),
      uuid: uuid,
      cleared: false
    ]

    {:ok, assign(socket, assigns), temporary_assigns: [requests: []]}
  end

  def handle_info({Lasso, _uuid, {:request, request}}, socket) do
    all_requests = Enum.take([request | socket.assigns.requests], @request_limit)
    {:noreply, assign(socket, requests: all_requests, cleared: false)}
  end

  def handle_info({Lasso, _uuid, :clear}, socket) do
    {:noreply, assign(socket, requests: [], cleared: true)}
  end

  def handle_info({Lasso, _uuid, :delete}, socket) do
    {:noreply, redirect(socket, to: "/")}
  end

  def handle_event("clear", _, %{assigns: %{uuid: uuid}} = socket) do
    Logger.info("Clearing requests for lasso with uuid: #{uuid}")
    socket = clear(socket, uuid)
    {:noreply, assign(socket, requests: [], cleared: true)}
  end

  def handle_event("delete", _, %{assigns: %{uuid: uuid}} = socket) do
    Logger.info("Deleting lasso with uuid: #{uuid}")

    socket =
      socket
      |> delete(uuid)
      |> redirect(to: "/")

    {:noreply, socket}
  end

  defp clear(socket, uuid) do
    case Lasso.clear(uuid) do
      :ok ->
        put_flash(socket, :info, "Successfully cleared lasso: #{uuid}")

      error ->
        put_flash(socket, :error, "Failed to clear lasso #{uuid}, due to: #{inspect(error)}")
    end
  end

  defp delete(socket, uuid) do
    case Lasso.delete(uuid) do
      :ok ->
        put_flash(socket, :info, "Successfully deleted lasso: #{uuid}")

      error ->
        put_flash(socket, :error, "Failed to delete lasso #{uuid}, due to: #{inspect(error)}")
    end
  end
end
