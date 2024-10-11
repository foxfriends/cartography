defmodule Cartography.Field do
  use Ecto.Schema

  @primary_key false
  @derive Jason.Encoder

  schema "fields" do
    field(:id, :integer, primary_key: true)
    field(:name, :string)
    field(:account_id, :string)
    field(:grid_x, :integer)
    field(:grid_y, :integer)
    field(:width, :integer)
    field(:height, :integer)
  end
end
