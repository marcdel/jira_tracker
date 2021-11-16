import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :jira_tracker, JiraTrackerWeb.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :jira_tracker, JiraTrackerWeb.Endpoint,
#       ...,
#       url: [host: "example.com", port: 443],
#       https: [
#         ...,
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :jira_tracker, JiraTrackerWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

config :jira_tracker, JiraTrackerWeb.Endpoint,
  # Possibly not needed, but doesn't hurt
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  server: true

config :jira_tracker, JiraTracker.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  # Free tier db only allows 4 connections. Rolling deploys need pool_size*(n+1) connections where n is the number of app replicas.
  pool_size: 2

# Configure OpenTelemetry Exporter
api_key = Map.fetch!(System.get_env(), "HONEYCOMB_KEY")

config :opentelemetry, :processors,
  otel_batch_processor: %{
    exporter:
      {:opentelemetry_exporter,
       %{
         protocol: :grpc,
         headers: [
           {'x-honeycomb-team', api_key},
           {'x-honeycomb-dataset', 'jira_tracker'}
         ],
         endpoints: [{:https, 'api.honeycomb.io', 443, []}]
       }}
  }
