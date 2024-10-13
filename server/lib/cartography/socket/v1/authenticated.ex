defmodule Cartography.Socket.V1.Authenticated do
  @moduledoc """
  Authenticated state handlers for V1 socket protocol.
  """

  def handle_message(
        "place_card",
        %{"card_id" => _card_id, "field_id" => _field_id, "x" => _x, "y" => _y},
        %{account_id: account_id} = state
      ) do
    Cartography.Database.as_account_id!(account_id, fn ->
      {:ok, state}
    end)
  end
end
