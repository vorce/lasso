defmodule Lasso.HookTest do
  use ExUnit.Case

  alias Lasso.Hook

  describe "create/1" do
    test "create and get" do
      uuid = "myid"
      assert Hook.create(uuid) == :ok
      assert Hook.get(uuid) == {:ok, []}
    end
  end

  describe "get/1" do
    test "return error tuple on unknown uuid" do
      uuid = "unknown"
      assert Hook.get(uuid) == {:error, :no_such_key, uuid}
    end
  end

  describe "add/1" do
    test "add and get" do
      uuid = "addtest"
      request = %{}
      assert Hook.add(uuid, request) == :ok
      assert Hook.get(uuid) == {:ok, [request]}
    end

    test "add multiple and get" do
      uuid = "addmultipletest"
      request1 = %{id: 1}
      request2 = %{id: 2}

      assert Hook.add(uuid, request1) == :ok
      assert Hook.add(uuid, request2) == :ok
      assert Hook.get(uuid) == {:ok, [request2, request1]}
    end
  end
end
