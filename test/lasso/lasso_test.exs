defmodule Lasso.LassoTest do
  use ExUnit.Case

  setup do
    # Ensure the cache is cleared before each test
    Supervisor.terminate_child(Lasso.Supervisor, ConCache)
    Supervisor.restart_child(Lasso.Supervisor, ConCache)
    :ok
  end

  describe "create/1" do
    test "create and get" do
      uuid = "myid"
      assert Lasso.create(uuid) == :ok
      assert Lasso.get(uuid) == {:ok, []}
    end
  end

  describe "get/1" do
    test "return error tuple on unknown uuid" do
      uuid = "unknown"
      assert Lasso.get(uuid) == {:error, :no_such_key, uuid}
    end
  end

  describe "add/1" do
    test "add and get" do
      uuid = "addtest"
      request = %{}
      assert Lasso.add(uuid, request) == :ok
      assert Lasso.get(uuid) == {:ok, [request]}
    end

    test "add multiple and get" do
      uuid = "addmultipletest"
      request1 = %{id: 1}
      request2 = %{id: 2}

      assert Lasso.add(uuid, request1) == :ok
      assert Lasso.add(uuid, request2) == :ok
      assert Lasso.get(uuid) == {:ok, [request2, request1]}
    end
  end

  describe "delete/1" do
    test "removes lasso" do
      lasso_id = "foo"
      Lasso.create(lasso_id)

      assert Lasso.get(lasso_id) == {:ok, []}

      Lasso.delete(lasso_id)

      assert Lasso.get(lasso_id) == {:error, :no_such_key, lasso_id}
    end
  end

  describe "stats/0" do
    test "returns active lassos" do
      Lasso.create("1")
      Lasso.create("2")
      Lasso.create("3")
      Lasso.delete("2")

      assert {:ok, %{active_lassos: 2}} = Lasso.stats()
    end

    test "returns total lassos" do
      Lasso.create("1")
      Lasso.create("2")
      Lasso.create("3")
      Lasso.delete("2")

      assert {:ok, %{total_lassos: 3}} = Lasso.stats()
    end
  end
end
