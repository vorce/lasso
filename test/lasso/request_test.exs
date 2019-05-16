defmodule Lasso.RequestTest do
  use ExUnit.Case

  alias Lasso.Request

  describe "from/1" do
    test "creates struct from conn" do
      conn = %Plug.Conn{remote_ip: {127, 0, 0, 1}, method: "GET"}
      assert %Request{ip: "127.0.0.1", method: "GET"} = Request.from(conn)
    end
  end
end
