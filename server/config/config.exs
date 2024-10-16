import Config

config :cartography,
  host: {0, 0, 0, 0},
  env: config_env()

config :cartography, Cartography.Database, enabled: true
config :cartography, Cartography.Notifications, enabled: true

import_config "#{config_env()}.exs"
