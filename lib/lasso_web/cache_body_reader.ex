defmodule LassoWeb.CacheBodyReader do
  @moduledoc """
  Make sure we can get to the raw body
  """
  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    # body = [body | conn.private[:raw_body] || []]
    conn = Plug.Conn.put_private(conn, :raw_body, body)
    {:ok, body, conn}
  end

  # TODO do I wanna support bigger bodies?
  defp read_full_body({:ok, body, conn}, acc) do
    Enum.reverse([body | acc])
  end

  defp read_full_body({:more, partial_body, conn}, acc) do
    read_full_body(Plug.Conn.read_body(conn), [partial_body | acc])
  end
end
