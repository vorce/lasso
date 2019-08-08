defmodule LassoWeb.AdminLiveView do
  use Phoenix.LiveView

  require Logger

  @admin_events Application.get_env(:lasso, Lasso)[:admin_events_topic]

  def render(assigns) do
    LassoWeb.AdminView.render("index.html", assigns)
  end

  def mount(session, socket) do
    Lasso.subscribe(@admin_events)

    {:ok,
     assign(socket, active_lassos: session.active_lassos, total_lassos: session.total_lassos)}
  end

  def handle_info({Lasso, @admin_events, {:stats, stats}}, socket) do
    {:noreply,
     assign(socket, active_lassos: stats.active_lassos, total_lassos: stats.total_lassos)}
  end
end
