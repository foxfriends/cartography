defmodule Cartography.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/websocket" do
    conn
    |> WebSockAdapter.upgrade(Cartography.Socket, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
