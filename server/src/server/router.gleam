import gleam/bytes_tree
import gleam/http/request
import gleam/http/response
import mist
import server/context.{type Context}
import websocket/handler

pub fn handler(req: request.Request(mist.Connection), context: Context) {
  case request.path_segments(req) {
    ["websocket"] -> {
      case handler.start(req, context) {
        Ok(response) -> response
        Error(_) ->
          response.new(400)
          |> response.set_body(mist.Bytes(bytes_tree.new()))
      }
    }
    _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}
