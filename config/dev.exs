import Config

config :shop, Shop.Repo,
  url: System.get_env("DATABASE_URL"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  ssl: true

config :shop, ShopWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT") || "4000")],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "3emysq1IQToT0o2Xmxn0Y3m/1+v3W1W5+RlaCm1IUCV7oNplBj3W/3WVsjNx+zMw",
  watchers: []

config :shop, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :swoosh, :api_client, false
