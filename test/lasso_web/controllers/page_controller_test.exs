defmodule LassoWeb.PageControllerTest do
  use LassoWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Lasso"
  end
end
