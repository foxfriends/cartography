import Config

config :cartography,
  port: System.get_env("PORT", "4000")
