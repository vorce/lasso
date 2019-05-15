defmodule Lasso.Hook do
  @moduledoc """
  Contains state of all active hooks
  """
  @cache_id :hook_cache

  @topic inspect(__MODULE__)

  def subscribe(uuid) do
    Phoenix.PubSub.subscribe(Lasso.PubSub, @topic <> uuid)
  end

  defp notify_subscribers(uuid, request) do
    Phoenix.PubSub.broadcast(Lasso.PubSub, @topic <> uuid, {__MODULE__, uuid, request})
  end

  @doc """
  Create a new hook that we need to keep track of
  """
  def create(uuid) do
    ConCache.put(@cache_id, uuid, [])
  end

  def get(uuid) do
    case ConCache.get(@cache_id, uuid) do
      nil -> {:error, :no_such_key, uuid}
      value -> {:ok, value}
    end
  end

  def add(uuid, request) do
    # TODO limit to 100 requests per hook?
    with :ok <- update(uuid, request) do
      notify_subscribers(uuid, request)
    end
  end

  defp update(uuid, request) do
    ConCache.update(@cache_id, uuid, fn val ->
      case val do
        nil -> {:ok, [request]}
        val -> {:ok, [request | val]}
      end
    end)
  end
end
