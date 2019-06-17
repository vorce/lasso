defmodule LassoWeb.LassoControllerTest do
  use LassoWeb.ConnCase

  describe "GET /lasso/:uuid" do
    test "returns 410 for unknown", %{conn: conn} do
      conn = get(conn, "/lasso/123")
      assert response(conn, 410) =~ "lasso"
    end
  end
end
