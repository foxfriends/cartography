defmodule Cartography.Socket.V1.Authenticated do
  @moduledoc """
  Authenticated state handlers for V1 socket protocol.
  """

  def handle_message(
        "place_card",
        %{"card_id" => card_id, "field_id" => field_id, "x" => _x, "y" => _y},
        %{account_id: account_id} = state
      ) do
    {:ok, state}
  end
end
