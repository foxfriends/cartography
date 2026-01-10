import context.{type Context}
import dto/input_action
import dto/input_message
import gleam/http/request
import gleam/json
import gleam/option
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import handlers/auth_handler
import handlers/get_field_handler
import handlers/get_fields_handler
import handlers/subscribe_handler
import handlers/unsubscribe_handler
import mist.{type WebsocketConnection, type WebsocketMessage, Text}
import palabres
import websocket/state

fn as_text(message: WebsocketMessage(_msg)) {
  case message {
    Text(text) -> Ok(text)
    _ -> Error("only text messages are supported")
  }
}

fn parse_message(
  text: String,
  cb: fn(input_message.InputMessage) -> Result(t, String),
) -> Result(t, String) {
  let before = timestamp.system_time()

  let parsed =
    json.parse(from: text, using: input_message.decoder())
    |> result.map_error(string.inspect)

  case parsed {
    Ok(message) -> {
      palabres.info("message received")
      |> palabres.string(
        "timestamp",
        timestamp.to_rfc3339(before, calendar.utc_offset),
      )
      |> palabres.string("socket_message", string.inspect(message))
      |> palabres.log()

      let result = cb(message)

      let after = timestamp.system_time()
      let elapsed = timestamp.difference(before, after)
      palabres.info("message handled")
      |> palabres.string(
        "timestamp",
        timestamp.to_rfc3339(before, calendar.utc_offset),
      )
      |> palabres.string("duration", duration.to_iso8601_string(elapsed))
      |> palabres.string("socket_message", string.inspect(message))
      |> palabres.log()

      result
    }
    Error(error) -> {
      let after = timestamp.system_time()
      let elapsed = timestamp.difference(before, after)
      palabres.info("invalid message not handled")
      |> palabres.string(
        "timestamp",
        timestamp.to_rfc3339(before, calendar.utc_offset),
      )
      |> palabres.string("duration", duration.to_iso8601_string(elapsed))
      |> palabres.string("socket_message", text)
      |> palabres.log()

      Error(error)
    }
  }
}

fn handle_message(
  state: state.State,
  message: WebsocketMessage(_msg),
  conn: WebsocketConnection,
) -> mist.Next(state.State, _msg) {
  let response = {
    use text <- result.try(as_text(message))
    use message <- parse_message(text)
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

pub fn socket_handler(
  request: request.Request(mist.Connection),
  context: Context,
) {
  palabres.info("websocket connection received")
  |> palabres.string(
    "timestamp",
    timestamp.to_rfc3339(timestamp.system_time(), calendar.utc_offset),
  )
  |> palabres.log()

  mist.websocket(
    request: request,
    handler: handle_message,
    on_init: fn(_conn) { #(state.new(context), option.None) },
    on_close: fn(_state) {
      palabres.info("websocket connection closed")
      |> palabres.string(
        "timestamp",
        timestamp.to_rfc3339(timestamp.system_time(), calendar.utc_offset),
      )
      |> palabres.log()
      Nil
    },
  )
}
