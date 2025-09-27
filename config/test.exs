import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :shop, Shop.Repo,
  username: "postgres",
  password: System.get_env("PG_USER_PASS"),
  hostname: "localhost",
  database: "shop_co_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shop, ShopWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "3emysq1IQToT0o2Xmxn0Y3m/1+v3W1W5+RlaCm1IUCV7oNplBj3W/3WVsjNx+zMw",
  server: false

config :shop, ShopWeb.Auth.Guardian,
  issuer: "shop",
  secret_key: "test_secret_key"

# In test we don't send emails
config :shop, Shop.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
