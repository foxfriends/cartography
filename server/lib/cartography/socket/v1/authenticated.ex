defmodule Cartography.Socket.V1.Authenticated do
  @moduledoc """
  Authenticated state handlers for V1 socket protocol.
  """

  alias Cartography.Socket.V1
  alias Cartography.Socket.V1.FieldsListener

  def handle_message("watch_fields", %{}, message_id, state) do
    Cartography.NotificationSupervisor.start_listener(
      FieldsListener,
      [socket: self(), account_id: state.account_id, subscription_id: message_id],
      name: message_id
    )

    {:ok, state}
  end

  def handle_message("unsubscribe", %{}, message_id, state) do
    {:ok, _} = Cartography.NotificationSupervisor.stop_listener(message_id)

    {:ok, state}
  end

  def handle_message(
        "place_card",
        %{"card_id" => _card_id, "field_id" => _field_id, "x" => _x, "y" => _y},
        message_id,
        state
      ) do
    Cartography.Database.as_account_id!(state.account_id, fn ->
      {:push, {:json, V1.message("ack", %{}, message_id)}, state}
    end)
  end
end
