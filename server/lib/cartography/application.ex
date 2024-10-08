defmodule Cartography.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Cartography.Repo,
      {Bandit,
       plug: Cartography.Router,
       ip: Application.fetch_env!(:cartography, :host),
       port: Application.fetch_env!(:cartography, :port)}
    ]

    opts = [strategy: :one_for_one, name: Cartography.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
