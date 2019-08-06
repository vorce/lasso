defmodule LassoWeb.AdminController do
  use LassoWeb, :controller
  alias Phoenix.LiveView.Controller
  require Logger

  plug BasicAuth, use_config: {:lasso, :admin_area}

  def index(conn, _params) do
    with {:ok, stats} <- Lasso.stats() do
      Controller.live_render(
        conn,
        LassoWeb.AdminLiveView,
        session: stats
      )
    end
  end
end
