import dto/input_action
import dto/input_message
import gleam/http/request
import handlers/auth_handler
import handlers/get_field_handler
import handlers/get_fields_handler
import handlers/subscribe_handler
import handlers/unsubscribe_handler
import json_websocket
import mist.{type WebsocketConnection}
import palabres
import server/context.{type Context}
import websocket/state

fn handle_message(
  state: state.State,
  message: input_message.InputMessage,
  conn: WebsocketConnection,
) -> mist.Next(state.State, _msg) {
  let response = {
    case message.data {
      input_action.Auth(id) -> auth_handler.handle(state, conn, message.id, id)
      input_action.GetFields ->
        get_fields_handler.handle(state, conn, message.id)
      input_action.GetField(field_id) ->
        get_field_handler.handle(state, conn, message.id, field_id)
      input_action.Subscribe(channel) ->
        subscribe_handler.handle(state, conn, message.id, channel)
      input_action.Unsubscribe ->
        unsubscribe_handler.handle(state, conn, message.id)
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

pub fn start(request: request.Request(mist.Connection), context: Context) {
  state.new(context)
  |> json_websocket.new()
  |> json_websocket.message(input_message.decoder(), handle_message)
  |> json_websocket.start(request)
}
