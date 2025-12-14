defmodule Cartography.NotificationListener do
  alias Cartography.Notifications

  @callback handle_notification(
              event :: String.t(),
              target :: term(),
              subject :: term(),
              state
            ) ::
              {:noreply, state} | {:stop, reason :: term(), state}
            when state: var

  def init(channel, state) do
    Process.flag(:trap_exit, true)
    {_, listen_ref} = Notifications.listen(channel)
    {:ok, {%{listen_ref: listen_ref}, state}}
  end

  def terminate(_reason, %{listen_ref: listen_ref}) do
    Notifications.unlisten(listen_ref)

    :ok
  end

  defmacro __using__(_) do
    quote do
      use GenServer

      @behaviour Cartography.NotificationListener

      def child_spec([init, opts]) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [init, opts]},
          restart: :transient
        }
      end

      @impl GenServer
      @dialyzer {:no_match, handle_info: 2}
      def handle_info(
            {:notification, _notification_pid, _listen_ref, _channel, message},
            {internal, state}
          ) do
        decoded = Jason.decode!(message)

        case handle_notification(decoded["event"], decoded["target"], decoded["subject"], state) do
          {:noreply, new_state} -> {:noreply, {internal, new_state}}
          {:stop, reason, new_state} -> {:stop, reason, {internal, new_state}}
        end
      end

      @impl GenServer
      def terminate(reason, {internal, _state}) do
        Cartography.NotificationListener.terminate(reason, internal)
      end
    end
  end
end
