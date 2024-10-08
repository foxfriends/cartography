defmodule Cartography.Socket do
  @moduledoc """
  WebSocket handler for all game clients.
  """

  use Cartography.JsonWebSocket

  defmodule State do
    defstruct [:account_id]
  end

  @impl WebSock
  def init(_) do
    {:ok, %State{}}
  end

  @impl WebSock
  def handle_info(_, state) do
    {:ok, state}
  end

  @impl Cartography.JsonWebSocket
  def handle_json(%{"type" => "auth", "id" => id}, %{account_id: nil} = state)
      when is_binary(id) do
    with {:ok, _} <- Cartography.Repo.insert(%Cartography.Account{id: id}, on_conflict: :nothing),
         %Cartography.Account{id: id} = account <- Cartography.Repo.get!(Cartography.Account, id),
         do: {:push, {:json, %{id: id}}, %{state | account_id: id}}
  end
end
