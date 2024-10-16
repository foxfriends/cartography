defmodule Cartography.NotificationListener do
  alias Cartography.Notifications

  @callback handle_notification(message :: term(), state) ::
              {:noreply, state} | {:stop, reason :: term(), state}
            when state: var

  def init(channel, state) do
    {_, listen_ref} = Notifications.listen(channel)
    {:ok, {%{listen_ref: listen_ref}, state}}
  end

  def start_link(module, init_arg, options) do
    rename =
      {:via, Registry, {Cartography.NotificationRegistry, {self(), options[:name]}}}

    GenServer.start_link(module, init_arg, Keyword.merge([name: rename], options))
  end

  defmacro __using__(_) do
    quote do
      use GenServer

      @behaviour Cartography.NotificationListener

      def child_spec([init, opts]) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [init, opts]}
        }
      end

      @impl GenServer
      @dialyzer {:no_match, handle_info: 2}
      def handle_info(
            {:notification, _notification_pid, _listen_ref, _channel, message},
            {internal, state}
          ) do
        case handle_notification(message, state) do
          {:stop, reason, new_state} -> {:stop, reason, {internal, new_state}}
          {:noreply, new_state} -> {:noreply, {internal, new_state}}
        end
      end
    end
  end
end
