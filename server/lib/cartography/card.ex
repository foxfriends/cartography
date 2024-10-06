defmodule Cartography.Card do
  use Ecto.Schema

  schema "cards" do
    field(:id, :integer)
    field(:card_type_id, :string)
  end
end
