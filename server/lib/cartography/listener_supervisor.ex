defmodule Cartography.ListenerSupervisor do
  use DynamicSupervisor

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :transient
    }
  end

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, opts)
  end

  def start_child(supervisor, {module, args}, message_id) do
    args =
      Keyword.merge(args, socket: self(), subscription_id: message_id)

    opts =
      [name: {:via, Registry, {Cartography.Registry, {self(), message_id}}}]

    DynamicSupervisor.start_child(
      supervisor,
      {module, [args, opts]}
    )
  end

  def terminate_child(supervisor, message_id) do
    [{listener, _}] = Registry.lookup(Cartography.Registry, {self(), message_id})
    DynamicSupervisor.terminate_child(supervisor, listener)
  end

  @impl DynamicSupervisor
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def stop(pid) do
    DynamicSupervisor.stop(pid)
  end
end
