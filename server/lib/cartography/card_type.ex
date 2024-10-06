defmodule Cartography.CardType do
  use Ecto.Schema

  @primary_key false

  schema "card_types" do
    field(:id, :string, primary_key: true)
    field(:name, :string)
    field(:description, :string)
    field(:category, Ecto.Enum, values: [:residential, :production, :source, :trade])
  end
end
