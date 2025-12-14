defmodule Cartography.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  def accept_only(_, []), do: :unknown
  def accept_only(protocol, [protocol | _]), do: {:ok, protocol}
  def accept_only(protocol, [_ | protocols]), do: accept_only(protocol, protocols)

  def accept([], _), do: :unknown

  def accept([preferred | rest], supported) do
    case accept_only(preferred, supported) do
      :unknown -> accept(rest, supported)
      {:ok, protocol} -> {:ok, protocol}
    end
  end

  def negotiate_protocol(conn) do
    conn |> get_req_header("sec-websocket-protocol") |> accept(["v1.cartography.app"])
  end

  def upgrade(conn, "v1.cartography.app"),
    do: WebSockAdapter.upgrade(conn, Cartography.Socket.V1, [], timeout: :infinity)

  def negotiate_upgrade(conn) do
    case negotiate_protocol(conn) do
      {:ok, protocol} ->
        put_resp_header(conn, "sec-websocket-protocol", protocol)
        |> upgrade(protocol)

      :unknown ->
        send_resp(conn, 400, "No supported protocol requested")
    end
  end

  get "/websocket" do
    conn
    |> negotiate_upgrade()
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
