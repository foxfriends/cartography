import Config

config :cartography,
  port: System.get_env("PORT", "4000")

config :cartography, Cartography.Repo, url: System.get_env("DATABASE_URL")
