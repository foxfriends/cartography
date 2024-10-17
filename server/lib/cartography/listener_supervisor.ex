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

  def start_child(supervisor, {child, [args, opts]}) do
    opts =
      Keyword.merge(opts,
        name: {:via, Registry, {Cartography.Registry, {self(), child, opts[:name]}}}
      )

    DynamicSupervisor.start_child(
      supervisor,
      {child, [args, opts]}
    )
  end

  defdelegate terminate_child(supervisor, pid), to: DynamicSupervisor, as: :terminate_child

  @impl DynamicSupervisor
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def stop(pid) do
    DynamicSupervisor.stop(pid)
  end
end
