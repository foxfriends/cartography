defmodule Cartography.Socket.V1.Authenticated do
  @moduledoc """
  Authenticated state handlers for V1 socket protocol.
  """

  alias Cartography.Socket.V1
  alias Cartography.Socket.V1.FieldsListener

  def handle_message("subscribe", %{"channel" => "fields"}, message_id, state) do
    Cartography.ListenerSupervisor.start_child(
      state.supervisor,
      {FieldsListener,
       [
         [socket: self(), account_id: state.account_id, subscription_id: message_id],
         [name: message_id]
       ]}
    )

    {:ok, state}
  end

  def handle_message("subscribe", %{"channel" => "deck"}, message_id, state) do
    Cartography.ListenerSupervisor.start_child(
      state.supervisor,
      {CardAccountsListener,
       [
         [socket: self(), account_id: state.account_id, subscription_id: message_id],
         [name: message_id]
       ]}
    )

    {:ok, state}
  end

  def handle_message(
        "subscribe",
        %{"channel" => %{"topic" => "field_cards", "field_id" => field_id}},
        message_id,
        state
      ) do
    Cartography.ListenerSupervisor.start_child(
      state.supervisor,
      {FieldCardsListener,
       [
         [socket: self(), field_id: field_id, subscription_id: message_id],
         [name: message_id]
       ]}
    )

    {:ok, state}
  end

  def handle_message("unsubscribe", %{}, message_id, state) do
    [{listener, _}] = Registry.lookup(state.registry, message_id)
    :ok = Cartography.ListenerSupervisor.terminate_child(state.supervisor, listener)
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
