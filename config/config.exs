import Config

config :shop,
  ecto_repos: [Shop.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :shop, ShopWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ShopWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Shop.PubSub,
  live_view: [signing_salt: "xRYjya0L"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :shop, Shop.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :shop, ShopWeb.Auth.Guardian,
  issuer: "shop",
  secret_key: "GSGSGGS0-fGsbvhFf84pfu9LztCZfD3XHefMsXaGkvNyib4jlGUlD"

config :shop, :cloudinary,
  cloud_name: "dg0wlz4nh",
  api_key: "124145474263782",
  api_secret: "iE6m6q-V-jheTMUOQv20x4Q7BVA"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
