defmodule Cartography.Notifications do
  @name __MODULE__

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

  def listen(conn, channel), do: Postgrex.Notifications.listen(conn, channel)
end
