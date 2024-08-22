import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :practice_mate, PracticeMateWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vQ9yYvx6PZZkjb4DOB4KTPlaid2eJa1S1+vt2DI36R3VaF1FKd5eMyN8hWzZnM9W",
  server: false

config :practice_mate, :behaviours, spotify_request: PracticeMate.Support.MockSpotifyRequest

# In test we don't send emails
config :practice_mate, PracticeMate.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
