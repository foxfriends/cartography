defmodule Cartography.Field do
  use Ecto.Schema

  schema "fields" do
    field(:id, :integer)
    field(:name, :string)
    field(:account_id, :string)
    field(:grid_x, :integer)
    field(:grid_y, :integer)
    field(:width, :integer)
    field(:height, :integer)
  end
end
