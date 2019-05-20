defmodule LassoWeb.CacheBodyReader do
  @moduledoc """
  Make sure we can get to the raw body
  """
  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = Plug.Conn.put_private(conn, :raw_body, body)
    {:ok, body, conn}
  end
end
