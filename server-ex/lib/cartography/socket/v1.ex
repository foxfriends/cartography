defmodule Cartography.Socket.V1 do
  @moduledoc """
  WebSocket handler for all game clients.
  """

  use JsonWebSocket
  require Logger
  alias Cartography.Socket.V1.Authenticated
  alias Cartography.Socket.V1.Unauthenticated

  defmodule State do
    defstruct [:id, :account_id, :supervisor]
  end

  def message(type, data, id) do
    JsonWebSocket.json_message(%{type: type, data: data, id: id})
  end

  @impl WebSock
  def init(_) do
    id = UUID.uuid4()

    {:ok, supervisor} =
      DynamicSupervisor.start_child(
        Cartography.SocketSupervisor,
        {Cartography.ListenerSupervisor,
         name: {:via, Registry, {Cartography.Registry, {self(), __MODULE__}}}}
      )

    Logger.info("Socket #{id} connected")

    {:ok, %State{id: id, supervisor: supervisor}}
  end

  def handle_message(type, data, id, %{account_id: nil} = state),
    do: Unauthenticated.handle_message(type, data, id, state)

  def handle_message(type, data, id, state),
    do: Authenticated.handle_message(type, data, id, state)

  @impl JsonWebSocket
  def handle_json(%{"type" => type, "data" => data, "id" => id}, state) do
    handle_message(type, data, id, state)
  end

  def push(pid, messages) do
    send(pid, {:push, JsonWebSocket.encode_messages(messages)})
  end

  @impl WebSock
  def handle_info({:push, messages}, state) do
    {:push, messages, state}
  end

  @impl WebSock
  def terminate(reason, state) do
    Logger.info("Socket #{state.id} closing (#{inspect(reason)})")
    :ok = Cartography.ListenerSupervisor.stop(state.supervisor)
    :ok
  end
end
