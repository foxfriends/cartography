defmodule Cartography.Database do
  require Logger

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
      Postgrex.start_link(
        Keyword.merge(
          [name: @name, parameters: [application_name: "Cartography Server"]],
          config
        )
      )
    end
  end

  def raw!(sql, values \\ []), do: raw!(@name, sql, values)

  def raw!(conn, sql, values, opts \\ []) do
    with %{num_rows: num_rows, rows: rows, columns: columns} <-
           Postgrex.query!(conn, sql, values, opts) do
      cols = columns |> Enum.map(&String.to_atom/1)

      %{
        num_rows: num_rows,
        rows: Enum.map(rows, fn row -> map_cols(row, cols) end)
      }
    end
  end

  defp map_cols(row, columns) do
    columns
    |> Enum.zip(row)
    |> Map.new()
  end

  def query!(%Sql{} = sql), do: query!(@name, sql)

  def query!(conn, %Sql{} = sql, opts \\ []) do
    {sql, values} = Sql.to_query(sql)
    Logger.debug(sql)
    raw!(conn, sql, values, opts)
  end

  def one!(sql) do
    case query!(sql) do
      %{rows: []} -> nil
      %{rows: [row]} -> row
      _ -> raise "one! multiple rows returned by query"
    end
  end

  def all!(sql), do: query!(sql).rows

  def transaction!(fun), do: transaction!(@name, fun)

  def transaction!(conn, fun, opts \\ []) do
    case Postgrex.transaction(conn, fun, opts) do
      {:ok, res} -> res
      {:error, :rollback} -> raise "transaction! rollback"
      err -> err
    end
  end
end
