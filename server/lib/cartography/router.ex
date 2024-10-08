defmodule Cartography.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  def accept_only([], _), do: :unknown
  def accept_only([protocol | _], protocol), do: {:ok, protocol}
  def accept_only([_ | protocols], protocol), do: accept_only(protocols, protocol)

  def accept(_, []), do: :unknown

  def accept(protocols, [protocol | non_preferred]) do
    case accept_only(protocols, protocol) do
      :unknown -> accept(protocols, non_preferred)
      {:ok, protocol} -> {:ok, protocol}
    end
  end

  def negotiate_protocol(conn) do
    conn |> get_req_header("sec-websocket-protocol") |> accept(["cartography-v1"])
  end

  def upgrade(conn) do
    case negotiate_protocol(conn) do
      {:ok, "cartography-v1"} ->
        WebSockAdapter.upgrade(conn, Cartography.Socket, [], timeout: 60_000)

      :unknown ->
        send_resp(conn, 400, "No supported protocol requested")
    end
  end

  get "/websocket" do
    conn
    |> upgrade()
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
