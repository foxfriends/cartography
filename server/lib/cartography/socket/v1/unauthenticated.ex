defmodule Cartography.Socket.V1.Unauthenticated do
  @moduledoc """
  Unauthenticated state handlers for V1 socket protocol.
  """

  import Sql

  def handle_message("auth", %{"id" => id}, state)
      when is_binary(id) do
    account =
      with nil <-
             Cartography.Database.one!(
               ~q"INSERT INTO accounts (id) VALUES (#{id}) ON CONFLICT DO NOTHING RETURNING *"
             ) do
        Cartography.Database.one!(~q"SELECT * FROM accounts WHERE id = #{id}")
      end

    {:push, {:json, %{id: account.id}}, %{state | account_id: account.id}}
  end
end
