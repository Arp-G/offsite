import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :offsite, OffsiteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zM25uPNu2XjXBf8VTPWCjawIAd/Ji2dE6U72agdvW6NeGEDLTji+PqsIoTJN9UAh",
  server: false

# In test we don't send emails.
config :offsite, Offsite.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
