defmodule Cartography.NotificationSupervisor do
  @moduledoc """
  Supervisor for Postgres `LISTEN`-ers
  """

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(child_spec) do
    opts = [
      name: {:via, Registry, {Cartography.NotificationRegistry, child_spec.name}}
    ]

    DynamicSupervisor.start_child(__MODULE__, Keyword.merge(opts, child_spec))
  end

  @impl DynamicSupervisor
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
