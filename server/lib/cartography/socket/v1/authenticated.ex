defmodule Cartography.Socket.V1.Authenticated do
  @moduledoc """
  Authenticated state handlers for V1 socket protocol.
  """

  import Sql
  alias Cartography.Database
  alias Cartography.Socket.V1
  alias Cartography.Socket.V1.CardAccountsListener
  alias Cartography.Socket.V1.FieldCardsListener
  alias Cartography.Socket.V1.FieldsListener

  defp listener("fields", %{account_id: account_id}),
    do: {FieldsListener, account_id: account_id}

  defp listener("deck", %{account_id: account_id}),
    do: {CardAccountsListener, account_id: account_id}

  defp listener(%{"topic" => "field_cards", "field_id" => field_id}, _state),
    do: {FieldCardsListener, field_id: field_id}

  def handle_message("subscribe", %{"channel" => channel}, message_id, state) do
    {:ok, _} =
      Cartography.ListenerSupervisor.start_child(
        state.supervisor,
        listener(channel, state),
        message_id
      )

    {:ok, state}
  end

  def handle_message("unsubscribe", %{}, message_id, state) do
    :ok = Cartography.ListenerSupervisor.terminate_child(state.supervisor, message_id)
    {:ok, state}
  end

  def handle_message(
        "get_fields",
        %{},
        message_id,
        state
      ) do
    fields = Database.all!(~q"SELECT * FROM fields WHERE account_id = #{state.account_id}")
    {:push, {:json, V1.message("fields", %{fields: fields}, message_id)}, state}
  end

  def handle_message(
        "place_card",
        %{"card_id" => _card_id, "field_id" => _field_id, "x" => _x, "y" => _y},
        message_id,
        state
      ) do
    {:push, {:json, V1.message("ack", %{}, message_id)}, state}
  end
end
