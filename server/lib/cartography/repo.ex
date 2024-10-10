defmodule Cartography.Repo do
  import Sql

  use Ecto.Repo,
    otp_app: :cartography,
    adapter: Ecto.Adapters.Postgres

  def sql!(sql) do
    {str, params} = Sql.to_query(sql)
    query!(str, params)
  end

  def set_local(setting, value) do
    sql!(~q"SET LOCAL #{identifier(setting)} = #{value}")
  end

  @spec as_account_id(String.t(), (... -> any)) :: {:ok, any} | {:error, any()}
  def as_account_id(account_id, callback) do
    transaction(fn repo ->
      set_local("cartography.current_account_id", account_id)

      if Function.info(callback)[:arity] == 1 do
        callback.(repo)
      else
        callback.()
      end
    end)
  end
end
