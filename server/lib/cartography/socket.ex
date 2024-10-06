defmodule Cartography.Socket do
  @moduledoc """
  WebSocket handler for all game clients.
  """

  def init(options) do
    {:ok, options}
  end

  def handle_in({"ping", [opcode: :text]}, state) do
    {:reply, :ok, {:text, "pong"}, state}
  end
end
