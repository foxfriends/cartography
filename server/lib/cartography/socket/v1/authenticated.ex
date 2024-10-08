defmodule Cartography.Socket.V1.Authenticated do
  @moduledoc """
  Authenticated state handlers for V1 socket protocol.
  """

  def handle_json(%{}, state) do
    {:ok, state}
  end
end
