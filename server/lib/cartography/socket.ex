defmodule Cartography.Socket do
  @moduledoc """
  WebSocket handler for all game clients.
  """

  defmodule State do
    defstruct []
  end

  def init(_) do
    {:ok, %State{}}
  end

  def handle_in({"ping", [opcode: :text]}, state) do
    {:reply, :ok, {:text, "pong"}, state}
  end
end
