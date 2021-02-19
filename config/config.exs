# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :lasso, LassoWeb.Endpoint,
  url: [host: {:system, "APP_HOST"}],
  secret_key_base: "Onno9Q87iKwW3FJNhrqdagj16XBSkh7zQm2Kv1jFwnKsDfiTffYYH9SG3uXki55B",
  render_errors: [view: LassoWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Lasso.PubSub,
  live_view: [
    signing_salt: System.get_env("SECRET_SALT") || "38k3jc4wTIxlt16PsbudWeXe497ET9TM"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Admin page credentials
config :lasso, :basic_auth, username: "admin", password: System.get_env("ADMIN_PASSWORD")

config :lasso, Lasso,
  admin_events_topic: "_admin_events",
  max_requests_per_lasso: 100,
  cache_name: :lasso_cache

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
