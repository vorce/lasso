defmodule LassoWeb.LassoViewControllerTest do
  use LassoWeb.ConnCase

  test "an empty lasso has a placeholder", %{conn: conn} do
    conn = post(conn, "/admin/lasso/")

    assert conn.status == 302

    path = redirected_to(conn)
    [_, _, _uuid, _] = String.split(path, "/")

    # Which contains 0 requests to begin with
    placeholder? =
      conn
      |> lasso_view_html(path)
      |> placeholder?()

    assert placeholder?
  end

  test "create, view and update a lasso", %{conn: conn} do
    # Create lasso redirects to the lasso view
    conn = post(conn, "/admin/lasso/")

    assert conn.status == 302

    path = redirected_to(conn)
    [_, _, uuid, _] = String.split(path, "/")

    # Which contains 0 requests to begin with
    requests =
      conn
      |> lasso_view_html(path)
      |> request_list()

    assert requests == []

    # After posting to the lasso url, one request is shown on the page
    requests =
      uuid
      |> post_to_lasso(%{hello: "world"})
      |> lasso_view_html(path)
      |> request_list()

    assert length(requests) == 1
  end

  test "clear lasso", %{conn: conn} do
    conn = post(conn, "/admin/lasso/")

    assert conn.status == 302

    path = redirected_to(conn)
    [_, _, uuid, _] = String.split(path, "/")

    requests =
      conn
      |> lasso_view_html(path)
      |> request_list()

    assert requests == []

    requests =
      uuid
      |> post_to_lasso(%{hello: "world"})
      |> lasso_view_html(path)
      |> request_list()

    assert length(requests) == 1

    :ok = Lasso.clear(uuid)

    requests =
      conn
      |> lasso_view_html(path)
      |> request_list()

    assert requests == []
  end

  test "placeholder for empty body", %{conn: conn} do
    conn = post(conn, "/admin/lasso/")

    assert conn.status == 302

    path = redirected_to(conn)
    [_, _, uuid, _] = String.split(path, "/")

    [{_, _, [_, {_, _, [{_, _, [body_content]}]}]}] =
      uuid
      |> get_to_lasso()
      |> lasso_view_html(path)
      |> request_list()
      |> Floki.find("details#request-body")

    assert body_content =~ "No request body"
  end

  defp lasso_view_html(conn, path) do
    conn
    |> get(path)
    |> response(200)
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

  defp get_to_lasso(uuid) do
    get(build_conn(), "/lasso/#{uuid}")
  end

  defp placeholder?(html) do
    {:ok, document} = Floki.parse_document(html)

    case Floki.find(document, "div#no_requests") do
      [{"div", _, _}] -> true
      _ ->
        false
    end
  end
end
