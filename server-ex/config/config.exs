import Config

config :cartography,
  host: {0, 0, 0, 0},
  env: config_env()

config :cartography, Cartography.Database, enabled: true
config :cartography, Cartography.Notifications, enabled: true

config :logger,
  backends: [:console]

config :logger, :default_formatter,
  format: "[$dateT$time]: $metadata[$level] $message\n",
  metadata: []

import_config "#{config_env()}.exs"
