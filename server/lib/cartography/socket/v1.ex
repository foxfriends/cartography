defmodule Cartography.Socket.V1 do
  @moduledoc """
  WebSocket handler for all game clients.
  """

  use JsonWebSocket
  alias Cartography.Socket.V1.{Authenticated, State, Unauthenticated}

  @impl WebSock
  def init(_) do
    {:ok, %State{}}
  end

  @impl WebSock
  def handle_info(_, state) do
    {:ok, state}
  end

  def handle_message(type, data, %{account_id: nil} = state),
    do: Unauthenticated.handle_message(type, data, state)

  def handle_message(type, data, state),
    do: Authenticated.handle_message(type, data, state)

  @impl JsonWebSocket
  def handle_json(%{"type" => type, "data" => data}, state) do
    handle_message(type, data, state)
  end
end
