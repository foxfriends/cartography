defmodule Cartography.JsonWebSocket do
  @moduledoc """
  JSON specialized WebSocket handler behaviour and helpers.

  This will set `@behaviour WebSock` and implement most of the required callbacks, while
  also setting `@behaviour Cartography.JsonWebSocket` to require additional callbacks
  specialized for handling JSON messages.
  """

  @type message() :: {:json, term()} | WebSock.message()
  @type messages() :: message() | [message()]

  @typedoc "The result as returned from handle_json calls"
  @type handle_result() ::
          {:push, messages(), WebSock.state()}
          | {:reply, term(), messages(), WebSock.state()}
          | {:ok, WebSock.state()}
          | {:stop, {:shutdown, :restart} | term(), WebSock.state()}
          | {:stop, term(), WebSock.close_detail(), WebSock.state()}
          | {:stop, term(), WebSock.close_detail(), messages(), WebSock.state()}

  @callback handle_json(term(), WebSock.state()) :: handle_result()

  @spec encode_messages(messages()) :: WebSock.messages()

  def encode_messages({:json, text}), do: {:text, Jason.encode!(text)}

  def encode_messages([]), do: []

  def encode_messages([message | messages]),
    do: [encode_messages(message) | encode_messages(messages)]

  def encode_messages(message), do: message

  @spec encode_json(handle_result()) :: WebSock.handle_result()

  def encode_json({:push, messages, state}), do: {:push, encode_messages(messages), state}

  def encode_json({:reply, term, messages, state}),
    do: {:reply, term, encode_messages(messages), state}

  def encode_json({:stop, reason, close, messages, state}),
    do: {:stop, reason, close, encode_messages(messages), state}

  def encode_json(other), do: other

  defmacro __using__(_) do
    quote do
      @behaviour WebSock
      @behaviour Cartography.JsonWebSocket

      def handle_in({text, [opcode: :text]}, state) do
        case Jason.decode(text) do
          {:ok, data} ->
            handle_json(data, state)
            |> Cartography.JsonWebSocket.encode_json()

          {:error, error} ->
            {:stop, error, 4000, state}
        end
      end

      def handle_in({_, [opcode: :binary]}, state) do
        {:stop, :binary_data_received, 1003, state}
      end
    end
  end
end
