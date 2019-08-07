defmodule LassoWeb.AdminControllerTest do
  use LassoWeb.ConnCase

  describe "GET /admin" do
    test "returns 401 without credentials", %{conn: conn} do
      conn = get(conn, "/admin")
      assert response(conn, 401) =~ "Unauthorized"
    end

    test "returns 401 with incorrect credentials", %{conn: conn} do
      conn =
        conn
        |> using_basic_auth("root", "foo")
        |> get("/admin")

      assert response(conn, 401) =~ "Unauthorized"
    end

    test "returns 200 with correct credentials", %{conn: conn} do
      conn =
        conn
        |> using_basic_auth("admin", "test")
        |> get("/admin")

      assert response(conn, 200) =~ "Admin"
    end
  end

  defp using_basic_auth(conn, username, password) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    put_req_header(conn, "authorization", header_content)
  end
end
