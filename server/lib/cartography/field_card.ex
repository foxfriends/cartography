defmodule Cartography.FieldCard do
  use Ecto.Schema

  @primary_key false
  @derive Jason.Encoder

  schema "field_cards" do
    field(:card_id, :integer, primary_key: true)
    field(:account_id, :string)
    field(:field_id, :integer)
    field(:grid_x, :integer)
    field(:grid_y, :integer)
  end
end
