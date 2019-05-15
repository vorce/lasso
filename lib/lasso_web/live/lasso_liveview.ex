defmodule LassoWeb.LassoLiveView do
  use Phoenix.LiveView
  alias Phoenix.Socket.Broadcast

  require Logger

  def render(assigns) do
    LassoWeb.LassoView.render("lasso.html", assigns)
  end

  def mount(session, socket) do
    Lasso.Hook.subscribe(session.uuid)
    {:ok, assign(socket, requests: [], url: session.url, uuid: session.uuid)}
  end

  def handle_info({Lasso.Hook, uuid, request}, socket) do
    Logger.info("New request received for uuid: #{uuid}")
    all_requests = [request | socket.assigns.requests]
    {:noreply, assign(socket, :requests, all_requests)}
  end

  def handle_info(all, socket) do
    IO.inspect(all, label: "Unknown handle_info")
    {:noreply, socket}
  end
end
