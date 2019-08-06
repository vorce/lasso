defmodule Lasso.HookTest do
  use ExUnit.Case

  alias Lasso.Hook
  
  setup do
    # Ensure the cache is cleared before each test
    Supervisor.terminate_child(Lasso.Supervisor, ConCache)
    Supervisor.restart_child(Lasso.Supervisor, ConCache)
    :ok
  end

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
  
  describe "delete/1" do
  end
  
  describe "stats/0" do
    test "returns active lassos" do
      Hook.create("1")
      Hook.create("2")
      Hook.create("3")
      Hook.delete("2")
      
      assert {:ok, %{active_lassos: 2}} = Hook.stats()
    end
    
    test "returns total lassos" do
      Hook.create("1")
      Hook.create("2")
      Hook.create("3")
      Hook.delete("2")
      
      assert {:ok, %{total_lassos: 3}} = Hook.stats()
    end
  end
end
