defmodule LassoWeb.PageController do
  use LassoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", conn: conn)
  end
end
