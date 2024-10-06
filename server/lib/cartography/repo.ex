defmodule Cartography.Repo do
  use Ecto.Repo,
    otp_app: :cartography,
    adapter: Ecto.Adapters.Postgres
end
