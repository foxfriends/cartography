defmodule Cartography.CardAccount do
  use Ecto.Schema

  @primary_key false

  schema "card_accounts" do
    field(:card_id, :integer, primary_key: true)
    field(:account_id, :string)
  end
end
