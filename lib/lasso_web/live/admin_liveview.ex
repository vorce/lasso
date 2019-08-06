defmodule LassoWeb.AdminLiveView do
  use Phoenix.LiveView

  require Logger

  def render(assigns) do
    LassoWeb.AdminView.render("index.html", assigns)
  end

  def mount(session, socket) do
    # Lasso.subscribe(session.uuid)
    {:ok,
     assign(socket,
       active_lassos: session.active_lassos,
       total_lassos: session.total_lassos
     )}
  end

  def handle_info({Lasso.Hook, _uuid, _request}, _socket) do
    # Logger.info("New request received for uuid: #{uuid}")
    # all_requests = [request | socket.assigns.requests]
    # {:noreply, assign(socket, :requests, all_requests)}
  end
end
