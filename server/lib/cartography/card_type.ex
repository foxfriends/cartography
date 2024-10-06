defmodule Cartography.CardType do
  use Ecto.Schema

  schema "card_types" do
    field(:id, :string)
    field(:name, :string)
    field(:description, :string)
    field(:category, Ecto.Enum, values: [:residential, :production, :source, :trade])
  end
end
