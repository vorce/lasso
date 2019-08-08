defmodule LassoWeb.LassoLiveView do
  use Phoenix.LiveView

  require Logger

  @request_limit Application.get_env(:lasso, Lasso)[:max_requests_per_lasso]

  def render(assigns) do
    LassoWeb.LassoViewView.render("lasso.html", assigns)
  end

  def mount(session, socket) do
    Lasso.subscribe(session.uuid)
    {:ok, assign(socket, requests: session.requests, url: session.url, uuid: session.uuid)}
  end

  def handle_info({Lasso, uuid, {:request, request}}, socket) do
    Logger.debug("New request received for uuid: #{uuid}")
    all_requests = Enum.take([request | socket.assigns.requests], @request_limit)
    {:noreply, assign(socket, :requests, all_requests)}
  end

  def handle_info({Lasso, _uuid, :clear}, socket) do
    {:noreply, assign(socket, :requests, [])}
  end

  def handle_event("delete", uuid, socket) do
    Logger.info("Deleting lasso with uuid: #{uuid}")
    socket = with :ok <- Lasso.delete(uuid) do
      put_flash(socket, :info, "Successfully deleted lasso: #{uuid}")
    else
      error ->
        put_flash(socket, :error, "Failed to delete lasso #{uuid}, due to: #{inspect(error)}")
    end
    {:stop, redirect(socket, to: "/")}
  end

  def handle_event("clear", uuid, socket) do
    Logger.info("Clearing requests for lasso with uuid: #{uuid}")
    socket = with :ok <- Lasso.clear(uuid) do
      put_flash(socket, :info, "Successfully cleared lasso: #{uuid}")
    else
      error ->
        put_flash(socket, :error, "Failed to clear lasso #{uuid}, due to: #{inspect(error)}")
    end
    {:noreply, assign(socket, :requests, [])}
  end
end
