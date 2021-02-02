defmodule Lasso do
  @moduledoc """
  The API for lasso management
  """
  require Logger

  @cache_id Application.compile_env(:lasso, [Lasso, :cache_name])
  @request_limit Application.compile_env(:lasso, [Lasso, :max_requests_per_lasso])

  @topic inspect(__MODULE__)

  def subscribe(uuid) do
    Phoenix.PubSub.subscribe(Lasso.PubSub, @topic <> uuid)
  end

  @doc """
  Create a new lasso that we need to keep track of
  """
  def create(uuid, _opts \\ [update_stats: true]) do
    with_telemetry_events(
      fn -> ConCache.put(@cache_id, uuid, []) end,
      {:action, %{action: :create}}
    )
  end

  @doc """
  Get all the requests for a lasso
  """
  def get(uuid) do
    with_telemetry_events(
      fn ->
        case ConCache.get(@cache_id, uuid) do
          nil -> {:error, :no_such_key, uuid}
          value -> {:ok, value}
        end
      end,
      {:action, %{action: :get}}
    )
  end

  @doc """
  Append a request to a lasso
  """
  def add(uuid, request) do
    with_telemetry_events(
      fn ->
        with :ok <- update(uuid, request) do
          notify_subscribers(uuid, {:request, request})
        end
      end,
      {:request, %{request: request}}
    )
  end

  defp notify_subscribers(uuid, data) do
    Phoenix.PubSub.broadcast(Lasso.PubSub, @topic <> uuid, {__MODULE__, uuid, data})
  end

  @doc """
  Delete a lasso
  """
  def delete(uuid) do
    with_telemetry_events(
      fn ->
        ConCache.delete(@cache_id, uuid)
        notify_subscribers(uuid, :delete)
      end,
      {:action, %{action: :delete}}
    )
  end

  @doc """
  Clear all requests for a lasso
  """
  def clear(uuid) do
    with_telemetry_events(
      fn ->
        with {:ok, _} <- get(uuid),
             :ok <- create(uuid, update_stats: false) do
          notify_subscribers(uuid, :clear)
        end
      end,
      {:action, %{action: :clear}}
    )
  end

  @doc """
  Used to update stats for every lasso delete (regardless if it's due to ttl or the `delete/1` function)
  """
  def cache_callback({:update, _cache_pid, _key, _value}), do: :ok

  def cache_callback({:delete, _cache_pid, _key}) do
    emit_stop({:action, %{action: :delete}}, 1)
    :ok
  end

  defp update(uuid, request) do
    ConCache.update(@cache_id, uuid, fn val ->
      case val do
        nil ->
          {:ok, [request]}

        val ->
          Logger.info("Lasso #{uuid} has #{length(val)} existing entries")
          {:ok, Enum.take([request | val], @request_limit)}
      end
    end)
  end

  defp with_telemetry_events(my_fn, path_meta) do
    start_time = emit_start(path_meta)
    result = my_fn.()
    duration = System.monotonic_time() - start_time
    emit_stop(path_meta, duration)
    result
  end

  defp emit_start({path, meta}) do
    start_time_mono = System.monotonic_time()

    :telemetry.execute(
      [:lasso, path, :start],
      %{system_time: System.system_time()},
      meta
    )

    start_time_mono
  end

  defp emit_stop({path, meta}, duration) do
    :telemetry.execute(
      [:lasso, path, :stop],
      %{duration: duration},
      meta
    )
  end
end
