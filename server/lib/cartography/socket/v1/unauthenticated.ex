defmodule Cartography.Socket.V1.Unauthenticated do
  @moduledoc """
  Unauthenticated state handlers for V1 socket protocol.
  """

  def handle_json(%{"type" => "auth", "id" => id}, state)
      when is_binary(id) do
    with {:ok, _} <- Cartography.Repo.insert(%Cartography.Account{id: id}, on_conflict: :nothing),
         %Cartography.Account{id: id} <- Cartography.Repo.get!(Cartography.Account, id),
         do: {:push, {:json, %{id: id}}, %{state | account_id: id}}
  end
end
