defmodule LassoWeb.HookControllerTest do
  use LassoWeb.ConnCase

  describe "GET /hooks/:uuid" do
    test "returns 410 for unknown", %{conn: conn} do
      conn = get(conn, "/hooks/123")
      assert response(conn, 410) =~ "lasso"
    end
  end
end
