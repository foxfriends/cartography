defmodule Cartography.Account do
  use Ecto.Schema

  @primary_key false

  schema "accounts" do
    field(:id, :string, primary_key: true)
  end
end
