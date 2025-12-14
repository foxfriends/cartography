import context.{type Context}
import gleam/bytes_tree
import gleam/http/request
import gleam/http/response
import mist
import websocket

pub fn handler(req: request.Request(mist.Connection), context: Context) {
  case request.path_segments(req) {
    ["websocket"] -> websocket.socket_handler(req, context)
    _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}
