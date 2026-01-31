import cartography_api/request
import gleam/http/request as http
import handlers/authenticate_handler
import handlers/list_fields_handler
import json_websocket
import mist.{type WebsocketConnection}
import palabres
import server/context.{type Context}
import websocket/state

fn handle_message(
  state: state.State,
  message: request.Message,
  conn: WebsocketConnection,
) -> mist.Next(state.State, _msg) {
  let response = {
    case message.request {
      request.Authenticate(id) ->
        authenticate_handler.handle(state, conn, message.id, id)
      request.ListFields -> list_fields_handler.handle(state, conn, message.id)
      request.WatchField(_) -> {
        todo
      }
      request.DebugAddCard(_) -> {
        todo
      }
      request.Unsubscribe -> {
        todo
      }
    }
  }
  case response {
    Ok(next) -> next
    Error(error) -> {
      palabres.error("websocket handler failed")
      |> palabres.string("error", error)
      |> palabres.log()
      mist.stop_abnormal(error)
    }
  }
}

pub fn start(request: http.Request(mist.Connection), context: Context) {
  state.new(context)
  |> json_websocket.new()
  |> json_websocket.message(request.decoder(), handle_message)
  |> json_websocket.start(request)
}
