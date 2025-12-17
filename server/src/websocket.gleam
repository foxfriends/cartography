import account
import context.{type Context}
import gleam/http/request
import gleam/json
import gleam/option
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import mist.{type Next, type WebsocketConnection, type WebsocketMessage, Text}
import output_message
import palabres

import input_message

type State {
  State(context: Context, account_id: option.Option(String))
}

fn as_text(message: WebsocketMessage(_msg)) {
  case message {
    Text(text) -> Ok(text)
    _ -> Error("only text messages are supported")
  }
}

fn log_message(msg: input_message.InputMessage, cb: fn() -> t) -> t {
  let before = timestamp.system_time()
  let result = cb()
  let after = timestamp.system_time()
  let elapsed = timestamp.difference(before, after)

  palabres.info("message handled")
  |> palabres.string(
    "timestamp",
    timestamp.to_rfc3339(before, calendar.utc_offset),
  )
  |> palabres.string("duration", duration.to_iso8601_string(elapsed))
  |> palabres.string("socket_message", string.inspect(msg))
  |> palabres.log()

  result
}

fn send_message(
  message: output_message.OutputMessage,
  conn: WebsocketConnection,
) {
  let message =
    message
    |> output_message.to_json()
    |> json.to_string()
  mist.send_text_frame(conn, message)
}

fn handle_message(
  state: State,
  message: WebsocketMessage(_msg),
  conn: WebsocketConnection,
) -> Next(State, _msg) {
  let response = {
    use text <- result.try(as_text(message))
    use message <- result.try(
      json.parse(from: text, using: input_message.decoder())
      |> result.map_error(string.inspect),
    )
    use <- log_message(message)
    case message.data {
      input_message.Auth(id) -> {
        use _ <- result.map(
          send_message(
            output_message.OutputMessage(
              data: output_message.Account(account.Account(id: id)),
              id: message.id,
            ),
            conn,
          )
          |> result.map_error(string.inspect),
        )
        mist.continue(State(..state, account_id: option.Some(id)))
      }
      _ -> Ok(mist.stop())
    }
  }
  case response {
    Ok(next) -> next
    Error(error) -> {
      palabres.error("websocket handler failed")
      |> palabres.string("error", error)
      |> palabres.log()
      mist.stop()
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
    on_init: fn(_conn) { #(State(context, option.None), option.None) },
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
