import Config

config :cartography,
  host: {0, 0, 0, 0},
  env: config_env()

import_config "#{config_env()}.exs"
