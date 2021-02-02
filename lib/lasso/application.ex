defmodule Lasso.Application do
  @moduledoc false

  use Application

  @cache_name Application.compile_env(:lasso, [Lasso, :cache_name])

  def start(_type, _args) do
    children = [
      {ConCache,
       [
         name: @cache_name,
         ttl_check_interval: :timer.minutes(10),
         global_ttl: :timer.hours(24),
         ets_options: [:compressed],
         callback: &Lasso.cache_callback/1
       ]},
      {Phoenix.PubSub, name: Lasso.PubSub},
      LassoWeb.Telemetry,
      LassoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lasso.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LassoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
