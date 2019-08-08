defmodule Lasso do
  @moduledoc """
  The API for lasso management
  """
  require Logger

  @cache_id :lasso_cache
  @request_limit 100

  @active_lassos_key :active_lassos
  @total_lassos_key :total_lassos

  @admin_events "_admin_events"

  @topic inspect(__MODULE__)

  def subscribe(uuid) do
    Phoenix.PubSub.subscribe(Lasso.PubSub, @topic <> uuid)
  end

  @doc """
  Create a new lasso that we need to keep track of
  """
  def create(uuid) do
    ConCache.put(@cache_id, uuid, [])
    update_stats()
  end

  defp update_stats() do
    ConCache.update(@cache_id, @active_lassos_key, fn val ->
      case val do
        nil -> {:ok, 1}
        val -> {:ok, val + 1}
      end
    end)

    ConCache.update(@cache_id, @total_lassos_key, fn val ->
      case val do
        nil -> {:ok, 1}
        val -> {:ok, val + 1}
      end
    end)

    notify_stats()
  end

  @doc """
  Get all the requests for a lasso
  """
  def get(uuid) do
    case ConCache.get(@cache_id, uuid) do
      nil -> {:error, :no_such_key, uuid}
      value -> {:ok, value}
    end
  end

  @doc """
  Append a request to a lasso
  """
  def add(uuid, request) do
    with :ok <- update(uuid, request) do
      notify_subscribers(uuid, request)
    end
  end

  defp notify_subscribers(uuid, data) do
    Phoenix.PubSub.broadcast(Lasso.PubSub, @topic <> uuid, {__MODULE__, uuid, data})
  end

  @doc """
  Delete a lasso
  """
  def delete(uuid) do
    ConCache.delete(@cache_id, uuid)
  end

  @doc """
  Clear all requests for a lasso
  """
  def clear(uuid) do
    case get(uuid) do
      {:ok, _} -> create(uuid)
      error -> error
    end
  end

  @doc """
  Used to update stats for every lasso delete (regardless if it's due to ttl or the `delete/1` function)
  """
  def cache_callback({:update, _cache_pid, _key, _value}), do: :ok

  def cache_callback({:delete, _cache_pid, _key}) do
    ConCache.update(@cache_id, @active_lassos_key, fn val ->
      case val do
        nil -> {:ok, 0}
        val -> {:ok, max(0, val - 1)}
      end
    end)

    notify_stats()
  end

  @doc """
  Get statistics about lassos
  """
  def stats() do
    active_lassos = ConCache.get(@cache_id, @active_lassos_key) || 0
    total_lassos = ConCache.get(@cache_id, @total_lassos_key) || 0
    {:ok, %{active_lassos: active_lassos, total_lassos: total_lassos}}
  end

  defp notify_stats() do
    with {:ok, stats} <- stats() do
      notify_subscribers(@admin_events, {:stats, stats})
    end
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
end
