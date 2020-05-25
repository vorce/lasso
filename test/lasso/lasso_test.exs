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

  describe "clear/1" do
    test "empties the requests in lasso" do
      lasso_id = "foo"

      Lasso.create(lasso_id)
      Lasso.add(lasso_id, %{id: 1})
      Lasso.add(lasso_id, %{id: 1})

      assert {:ok, [_one, _two]} = Lasso.get(lasso_id)

      assert Lasso.clear(lasso_id) == :ok
      assert Lasso.get(lasso_id) == {:ok, []}
    end

    test "fails on unknown lasso" do
      assert {:error, :no_such_key, _} = Lasso.clear("unknown")
    end
  end

  describe "telemetry events" do
    setup :attach_telemetry_handlers

    test "on create" do
      Lasso.create("1")

      assert_receive {:telemetry_event, [:lasso, :action, :start], %{system_time: _},
                      %{action: :create}}

      assert_receive {:telemetry_event, [:lasso, :action, :stop], %{duration: _},
                      %{action: :create}}
    end

    test "on get" do
      Lasso.create("1")
      Lasso.get("1")

      assert_receive {:telemetry_event, [:lasso, :action, :start], %{system_time: _},
                      %{action: :get}}

      assert_receive {:telemetry_event, [:lasso, :action, :stop], %{duration: _}, %{action: :get}}
    end

    test "on delete" do
      Lasso.create("1")
      Lasso.delete("1")

      assert_receive {:telemetry_event, [:lasso, :action, :start], %{system_time: _},
                      %{action: :delete}}

      assert_receive {:telemetry_event, [:lasso, :action, :stop], %{duration: _},
                      %{action: :delete}}
    end

    test "on clear" do
      Lasso.create("1")
      Lasso.clear("1")

      assert_receive {:telemetry_event, [:lasso, :action, :start], %{system_time: _},
                      %{action: :clear}}

      assert_receive {:telemetry_event, [:lasso, :action, :stop], %{duration: _},
                      %{action: :clear}}
    end

    test "on request" do
      request = %Lasso.Request{method: "GET"}
      Lasso.create("1")
      Lasso.add("1", request)

      assert_receive {:telemetry_event, [:lasso, :request, :start], %{system_time: _},
                      %{request: request}}

      assert_receive {:telemetry_event, [:lasso, :request, :stop], %{duration: _},
                      %{request: request}}
    end
  end

  defp attach_telemetry_handlers(%{test: test}) do
    self = self()

    :ok =
      :telemetry.attach_many(
        "telementry-handler-#{test}",
        [
          [:lasso, :action, :start],
          [:lasso, :action, :stop],
          [:lasso, :request, :start],
          [:lasso, :request, :stop]
        ],
        fn name, measurements, metadata, _ ->
          send(self, {:telemetry_event, name, measurements, metadata})
        end,
        nil
      )
  end
end
