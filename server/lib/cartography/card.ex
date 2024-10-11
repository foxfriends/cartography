defmodule Cartography.Card do
  use Ecto.Schema

  @primary_key false
  @derive Jason.Encoder

  schema "cards" do
    field(:id, :integer, primary_key: true)
    field(:card_type_id, :string)
  end
end
