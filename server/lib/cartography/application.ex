defmodule Cartography.Application do
  @moduledoc false

  use Application

  defp parse_connection_url(url) do
    info = URI.parse(url)
    destructure([username, password], String.split(info.userinfo, ":"))
    "/" <> database = info.path

    [
      username: username,
      password: password,
      database: database,
      hostname: info.host,
      port: info.port
    ]
  end

  @impl true
  def start(_type, _args) do
    connection = parse_connection_url(Application.fetch_env!(:cartography, :database_url))

    children = [
      {Cartography.Database, connection},
      {Cartography.Notifications, connection},
      {Registry, keys: :unique, name: Cartography.NotificationRegistry},
      {Cartography.NotificationSupervisor, []},
      {Bandit,
       plug: Cartography.Router,
       ip: Application.fetch_env!(:cartography, :host),
       port: Application.fetch_env!(:cartography, :port)}
    ]

    opts = [strategy: :one_for_one, name: Cartography.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
