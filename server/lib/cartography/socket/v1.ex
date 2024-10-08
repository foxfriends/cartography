defmodule Cartography.Socket.V1 do
  @moduledoc """
  WebSocket handler for all game clients.
  """

  use Cartography.JsonWebSocket
  alias Cartography.Socket.V1.{State, Unauthenticated, Authenticated}

  @impl WebSock
  def init(_) do
    {:ok, %State{}}
  end

  @impl WebSock
  def handle_info(_, state) do
    {:ok, state}
  end

  @impl Cartography.JsonWebSocket
  def handle_json(message, %{account_id: nil} = state),
    do: Unauthenticated.handle_json(message, state)

  def handle_json(message, state),
    do: Authenticated.handle_json(message, state)
end
