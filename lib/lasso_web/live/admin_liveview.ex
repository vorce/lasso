defmodule LassoWeb.AdminLiveView do
  use Phoenix.LiveView

  require Logger

  @admin_events Application.compile_env(:lasso, [Lasso, :admin_events_topic])

  def render(assigns) do
    LassoWeb.AdminView.render("index.html", assigns)
  end

  def mount(_params, session, socket) do
    Lasso.subscribe(@admin_events)

    assigns = [
      active_lassos: Map.fetch!(session, "active_lassos"),
      total_lassos: Map.fetch!(session, "total_lassos")
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_info({Lasso, @admin_events, {:stats, stats}}, socket) do
    {:noreply,
     assign(socket, active_lassos: stats.active_lassos, total_lassos: stats.total_lassos)}
  end
end
