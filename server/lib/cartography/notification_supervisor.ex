defmodule Cartography.NotificationSupervisor do
  @moduledoc """
  Supervisor for Postgres `LISTEN`-ers
  """

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_listener(child, init, opts) do
    defaults = [
      name: {:via, Registry, {Cartography.NotificationRegistry, {self(), opts[:name]}}}
    ]

    DynamicSupervisor.start_child(__MODULE__, {child, [init, Keyword.merge(defaults, opts)]})
  end

  def stop_listener(name) do
    case Registry.lookup(Cartography.NotificationRegistry, {self(), name}) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      _ -> {:error, :not_found}
    end
  end

  @impl DynamicSupervisor
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
