defmodule Cartography.Socket.V1.FieldCardsListener do
  alias Cartography.Socket.V1
  use Cartography.NotificationListener

  defmodule State do
    defstruct [:socket, :subscription_id, :field_id]
  end

  def start_link(init_arg, opts) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  @impl GenServer
  def init(config) do
    field_id = config[:field_id]
    channel = "field_cards:#{field_id}"

    state = %State{
      socket: config[:socket],
      subscription_id: config[:subscription_id],
      field_id: field_id
    }

    Cartography.NotificationListener.init(channel, state)
  end

  @impl Cartography.NotificationListener
  def handle_notification("unplace_card", target, _subject, state) do
    V1.push(state.socket, {:json, V1.message("card", %{id: target}, state.subscription_id)})

    {:noreply, state}
  end

  @impl Cartography.NotificationListener
  def handle_notification("place_card", target, _subject, state) do
    V1.push(state.socket, {:json, V1.message("card", %{id: target}, state.subscription_id)})

    {:noreply, state}
  end
end
