defmodule Cartography.Notifications do
  @name __MODULE__

  require Logger

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(config) do
    if Application.get_env(:cartography, __MODULE__)[:enabled] == false do
      :ignore
    else
      Postgrex.Notifications.start_link(
        Keyword.merge(
          [name: @name, parameters: [application_name: "Cartography Server (Notifications)"]],
          config
        )
      )
    end
  end

  def listen(channel), do: listen(@name, channel)

  def listen(conn, channel) do
    Logger.debug("LISTEN #{Sql.escape_identifier(channel)}")
    Postgrex.Notifications.listen(conn, channel)
  end

  def unlisten(listen_ref), do: unlisten(@name, listen_ref)

  def unlisten(conn, listen_ref) do
    Logger.debug("UNLISTEN ...")
    Postgrex.Notifications.unlisten(conn, listen_ref)
  end
end
