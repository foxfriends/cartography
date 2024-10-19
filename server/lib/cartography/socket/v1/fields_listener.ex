defmodule Cartography.Socket.V1.FieldsListener do
  import Sql
  alias Cartography.Database
  alias Cartography.NotificationListener
  alias Cartography.Socket.V1
  use NotificationListener

  defmodule State do
    defstruct [:socket, :subscription_id, :account_id]
  end

  def start_link(init_arg, opts) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  @impl GenServer
  def init(config) do
    account_id = config[:account_id]
    channel = "fields:#{account_id}"

    state = %State{
      socket: config[:socket],
      subscription_id: config[:subscription_id],
      account_id: account_id
    }

    NotificationListener.init(channel, state)
  end

  @impl NotificationListener
  def handle_notification("new_field", target, _subject, state) do
    push_field(target, state)

    {:noreply, state}
  end

  @impl NotificationListener
  def handle_notification("edit_field", target, _subject, state) do
    push_field(target, state)

    {:noreply, state}
  end

  defp push_field(id, state) do
    field = Database.one!(~q"SELECT * FROM fields WHERE id = #{id}")
    V1.push(state.socket, {:json, V1.message("field", %{field: field}, state.subscription_id)})
  end
end
