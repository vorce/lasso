use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lasso, LassoWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Admin page credentials for tests
config :basic_auth,
  admin_area: [
    username: "admin",
    password: "test",
    realm: "Admin area"
  ]
