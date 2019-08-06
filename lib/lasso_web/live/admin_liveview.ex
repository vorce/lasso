defmodule LassoWeb.AdminLiveView do
  use Phoenix.LiveView

  require Logger

  @admin_events "_admin_events"

  def render(assigns) do
    LassoWeb.AdminView.render("index.html", assigns)
  end

  def mount(session, socket) do
    Lasso.subscribe(@admin_events)

    {:ok,
     assign(socket, active_lassos: session.active_lassos, total_lassos: session.total_lassos)}
  end

  def handle_event([:lasso, :created], measurements, _metadata, _config) do
    Logger.info("telemetry event: #{inspect(measurements)}")
  end

  def handle_info({Lasso, @admin_events, {:active_lassos, active}}, socket) do
    {:noreply, assign(socket, :active_lassos, active)}
  end

  def handle_info({Lasso, @admin_events, {:total_lassos, total}}, socket) do
    {:noreply, assign(socket, :total_lassos, total)}
  end
end
