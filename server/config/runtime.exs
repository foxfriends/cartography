import Config

config :cartography,
  port: System.get_env("PORT", "4000"),
  database_url: System.get_env("DATABASE_URL")
