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

  def handle_info({Lasso, uuid, :clear}, socket) do
    socket = clear(socket, uuid)
    {:noreply, assign(socket, :requests, [])}
  end

  def handle_info({Lasso, uuid, :delete}, socket) do
    socket = delete(socket, uuid)
    {:stop, redirect(socket, to: "/")}
  end

  def handle_event("clear", uuid, socket) do
    Logger.info("Clearing requests for lasso with uuid: #{uuid}")
    socket = clear(socket, uuid)
    {:noreply, assign(socket, :requests, [])}
  end

  def handle_event("delete", uuid, socket) do
    Logger.info("Deleting lasso with uuid: #{uuid}")
    socket = delete(socket, uuid)
    {:stop, redirect(socket, to: "/")}
  end

  defp clear(socket, uuid) do
    case Lasso.clear(uuid) do
      :ok -> put_flash(socket, :info, "Successfully cleared lasso: #{uuid}")
      error -> put_flash(socket, :error, "Failed to clear lasso #{uuid}, due to: #{inspect(error)}")
    end
  end

  defp delete(socket, uuid) do
    case Lasso.delete(uuid) do
      :ok -> put_flash(socket, :info, "Successfully deleted lasso: #{uuid}")
      error -> put_flash(socket, :error, "Failed to delete lasso #{uuid}, due to: #{inspect(error)}")
    end
  end
end
