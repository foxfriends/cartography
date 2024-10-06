defmodule Cartography.FieldCard do
  use Ecto.Schema

  schema "field_cards" do
    field(:card_id, :integer)
    field(:account_id, :string)
    field(:field_id, :integer)
    field(:grid_x, :integer)
    field(:grid_y, :integer)
  end
end
