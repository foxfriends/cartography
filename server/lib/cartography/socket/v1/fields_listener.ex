defmodule Cartography.Socket.V1.FieldsListener do
  use Cartography.NotificationListener

  defmodule State do
    defstruct [:account_id]
  end

  def start_link(init, opts) do
    Cartography.NotificationListener.start_link(__MODULE__, init, opts)
  end

  @impl GenServer
  def init(config) do
    account_id = config[:account_id]

    channel = "fields:#{account_id}"
    state = %State{account_id: account_id}

    Cartography.NotificationListener.init(channel, state)
  end

  @impl Cartography.NotificationListener
  def handle_notification(_message, state) do
    # TODO: get the data and push the response
    {:noreply, state}
  end
end
