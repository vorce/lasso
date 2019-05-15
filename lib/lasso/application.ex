defmodule Lasso.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {ConCache, [name: :hook_cache, ttl_check_interval: :timer.minutes(10), global_ttl: :timer.hours(24)]},

      # Start the endpoint when the application starts
      LassoWeb.Endpoint
      # Starts a worker by calling: Lasso.Worker.start_link(arg)
      # {Lasso.Worker, arg},
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
