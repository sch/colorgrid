use Mix.Config

config :colorgrid, ColorgridWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "https", host: "evening-atoll-82768.herokuapp.com", port: 443,
        force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")


# Do not print debug messages in production
config :logger, level: :info
