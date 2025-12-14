defmodule Sql do
  defstruct parts: [""]

  defp dq(str), do: "\"#{str}\""

  def raw(str), do: %Sql{parts: [str]}

  def escape_identifier(name), do: name |> String.replace("\"", "\"\"") |> dq()

  def identifier(name), do: name |> escape_identifier() |> raw()

  defp expand({:interpolate, %Sql{parts: parts}}), do: Enum.flat_map(parts, &expand/1)
  defp expand(part), do: [part]

  def to_query(%Sql{parts: parts}) do
    {sql, params} =
      parts
      |> Enum.flat_map(&expand/1)
      |> Enum.map_reduce([], fn
        {:interpolate, value}, values -> {"$#{length(values) + 1}", [value | values]}
        str, values -> {str, values}
      end)

    {Enum.join(sql), Enum.reverse(params)}
  end

  defp unstring(call) do
    with {:"::", [val, _type]} <- Macro.decompose_call(call),
         {Kernel, :to_string, [expr]} <- Macro.decompose_call(val) do
      quote do
        {:interpolate, unquote(expr)}
      end
    end
  end

  defp serialize_segment(str) when is_binary(str), do: str
  defp serialize_segment(expr), do: unstring(expr)

  @doc ~S"""
  Safely interpolates a SQL query into a `%Sql` struct, which can be converted
  to its resulting string and parameters using `Sql.to_query`.
  """
  defmacro sigil_q({:<<>>, _, segments}, _modifiers) do
    parts =
      segments
      |> Enum.map(&serialize_segment/1)

    quote do
      %Sql{parts: [unquote_splicing(parts)]}
    end
  end
end
