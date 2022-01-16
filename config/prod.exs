import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :offsite, OffsiteWeb.Endpoint,
  load_from_system_env: true,
  http: [port: {:system, "PORT"}],
  server: true,
  secret_key_base: secret_key_base,
  url: [host: "${APP_NAME}.gigalixirapp.com", port: 443],
  check_origin: false,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

if File.exists?("config/prod.secret.exs"), do: import_config("prod.secret.exs")
