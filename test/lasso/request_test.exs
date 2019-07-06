defmodule Lasso.RequestTest do
  use ExUnit.Case

  alias Lasso.Request

  describe "from/1" do
    test "creates struct from conn" do
      conn = %Plug.Conn{remote_ip: {127, 0, 0, 1}, method: "GET"}
      assert %Request{ip: '::1', method: "GET"} = Request.from(conn)
    end

    test "creates struct from conn with x-original-forwarded-for header" do
      conn = %Plug.Conn{
        remote_ip: {0, 0, 0, 0, 1},
        method: "GET",
        req_headers: [{"x-original-forwarded-for", "123.0.0.1, 84.216.227.220, 35.241.28.19"}]
      }

      assert %Request{ip: "84.216.227.220", method: "GET"} = Request.from(conn)
    end

    test "creates struct with badge_class" do
      conn = %Plug.Conn{
        method: "GET"
      }

      assert %Request{badge_class: "badge float-right badge-primary", method: "GET"} =
               Request.from(conn)
    end
  end
end
