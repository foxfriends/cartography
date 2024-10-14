defmodule Cartography.Socket.V1.FieldsListener do
  use GenServer

  defmodule State do
    defstruct [:account_id, :listen_ref]
  end

  def start_link(init) do
    GenServer.start_link(__MODULE__, init)
  end

  @impl GenServer
  def init(init) do
    account_id = init[:account_id]
    {_, listen_ref} = Cartography.Notifications.listen("fields:#{account_id}")
    {:ok, %State{account_id: account_id, listen_ref: listen_ref}}
  end

  @impl GenServer
  def handle_info({:notification, _notification_pid, _listen_ref, _channel, _message}, state) do
    # TODO
    {:ok, state}
  end
end
