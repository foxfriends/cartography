defmodule Cartography.Socket.V1 do
  @moduledoc """
  WebSocket handler for all game clients.
  """

  use JsonWebSocket
  alias Cartography.Socket.V1.Authenticated
  alias Cartography.Socket.V1.Unauthenticated

  defmodule State do
    defstruct [:account_id]
  end

  def message(type, data, id) do
    %{type: type, data: data, id: id}
  end

  @impl WebSock
  def init(_) do
    {:ok, %State{}}
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
  def handle_info(_, state) do
    {:ok, state}
  end
end
