import cartography_api/request
import envoy
import gleam/http/request as http
import gleam/http/response
import gleam/list
import gleam/result
import gleam/string
import handlers/authenticate_handler
import handlers/debug_add_card_handler
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
      request.DebugAddCard(card_id) ->
        debug_add_card_handler.handle(state, card_id)
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
  use protocol <- result.try(http.get_header(request, "sec-websocket-protocol"))
  start_with_protocol(string.split(protocol, on: ","), request, context)
}

fn start_with_protocol(
  protocol: List(String),
  request: http.Request(mist.Connection),
  context: Context,
) {
  let supported =
    envoy.get("WEBSOCKET_PROTOCOLS")
    |> result.unwrap("json")
    |> string.split(on: ",")

  let allow_json = list.contains(supported, "json")

  case protocol {
    [] -> Error(Nil)
    ["v1-json.cartography.app", ..] if allow_json ->
      state.new(context)
      |> json_websocket.new()
      |> json_websocket.message(request.decoder(), handle_message)
      |> json_websocket.start(request)
      |> response.set_header(
        "sec-websocket-protocol",
        "v1-json.cartography.app",
      )
      |> Ok()
    [_, ..rest] -> start_with_protocol(rest, request, context)
  }
}
