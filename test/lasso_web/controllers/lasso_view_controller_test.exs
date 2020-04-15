defmodule LassoWeb.LassoViewControllerTest do
  use LassoWeb.ConnCase

  test "create, view and update a lasso", %{conn: conn} do
    # Create lasso redirects to the lasso view
    conn = post(conn, "/admin/lasso/")

    assert conn.status == 302

    path = redirected_to(conn)
    [_, _, uuid, _] = String.split(path, "/")

    # Which contains 0 requests to begin with
    requests =
      get(conn, path)
      |> response(200)
      |> request_list()

    assert requests == []

    # After posting to the lasso url, one request is shown on the page
    requests =
      uuid
      |> post_to_lasso(%{hello: "world"})
      |> get(path)
      |> response(200)
      |> request_list()

    assert length(requests) == 1
  end

  defp request_list(html) do
    {:ok, document} = Floki.parse_document(html)
    [{"div", _, requests}] = Floki.find(document, "div#requests")
    requests
  end

  defp post_to_lasso(uuid, payload) do
    build_conn()
    |> put_req_header("content-type", "application/json")
    |> post("/lasso/#{uuid}", Jason.encode!(payload))
  end
end