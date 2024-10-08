defmodule Cartography.Socket do
  @moduledoc """
  WebSocket handler for all game clients.
  """

  defmodule State do
    defstruct [:user]
  end

  def init(_) do
    {:ok, %State{}}
  end

  def handle_json(data, state) do
    {:push, {:text, Jason.encode!(data)}, state}
  end

  def handle_in({text, [opcode: :text]}, state) do
    case Jason.decode(text) do
      {:ok, data} -> handle_json(data, state)
      {:error, error} -> {:stop, error, 4000, state}
    end
  end

  def handle_in({_, [opcode: :binary]}, state) do
    {:stop, :binary_data_received, 1003, state}
  end
end
