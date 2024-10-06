defmodule Cartography.CardAccount do
  use Ecto.Schema

  schema "card_accounts" do
    field(:card_id, :integer)
    field(:account_id, :string)
  end
end
