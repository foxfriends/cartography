defmodule Cartography.Socket.V1.Authenticated do
  @moduledoc """
  Authenticated state handlers for V1 socket protocol.
  """

  import Ecto.Query

  alias Cartography.FieldCard
  alias Cartography.Field
  alias Cartography.Card
  alias Cartography.CardAccount
  alias Cartography.Repo

  def handle_message(
        "load_all",
        _,
        %{account_id: account_id} = state
      ) do
    Repo.as_account_id(account_id, fn ->
      deck =
        Repo.all(
          from(ca in CardAccount,
            inner_join: c in Card,
            on: c.id == ca.card_id,
            where: ca.account_id == ^account_id
          )
        )

      fields =
        Repo.all(from(f in Field, where: f.account_id == ^account_id))

      field_cards = Repo.all(from(fc in FieldCard, where: fc.account_id == ^account_id))

      {:push,
       {:json,
        %{
          "deck" => deck,
          "fields" => fields,
          "field_cards" => field_cards
        }}, state}
    end)
  end

  def handle_message(
        "place_card",
        %{"card_id" => _card_id, "field_id" => _field_id, "x" => _x, "y" => _y},
        %{account_id: account_id} = state
      ) do
    Repo.as_account_id(account_id, fn ->
      {:ok, state}
    end)
  end
end
