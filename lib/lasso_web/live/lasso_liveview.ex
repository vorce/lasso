defmodule LassoWeb.LassoLiveView do
  use Phoenix.LiveView

  require Logger

  def render(assigns) do
    LassoWeb.LassoViewView.render("lasso.html", assigns)
  end

  def mount(session, socket) do
    Lasso.Hook.subscribe(session.uuid)
    {:ok, assign(socket, requests: session.requests, url: session.url, uuid: session.uuid)}
  end

  def handle_info({Lasso.Hook, uuid, request}, socket) do
    Logger.info("New request received for uuid: #{uuid}")
    all_requests = [request | socket.assigns.requests]
    {:noreply, assign(socket, :requests, all_requests)}
  end
end
