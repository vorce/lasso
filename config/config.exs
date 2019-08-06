# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :lasso, LassoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Onno9Q87iKwW3FJNhrqdagj16XBSkh7zQm2Kv1jFwnKsDfiTffYYH9SG3uXki55B",
  render_errors: [view: LassoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Lasso.PubSub, adapter: Phoenix.PubSub.PG2],
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
config :basic_auth, my_auth_with_system: [
  username: "admin",
  password: {:system, "ADMIN_PASSWORD"},
  realm: "Admin area"
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
