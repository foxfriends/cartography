defmodule Cartography.Socket.V1.FieldsListener do
  alias Cartography.Socket.V1
  use Cartography.NotificationListener

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

    Cartography.NotificationListener.init(channel, state)
  end

  @impl Cartography.NotificationListener
  def handle_notification("new_field", target, _subject, state) do
    V1.push(state.socket, {:json, V1.message("field", %{id: target}, state.subscription_id)})

    {:noreply, state}
  end
end
