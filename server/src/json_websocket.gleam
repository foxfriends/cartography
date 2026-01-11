import gleam/dynamic/decode
import gleam/http/request
import gleam/json
import gleam/option
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import mist.{type WebsocketConnection, type WebsocketMessage, Text}
import palabres

fn as_text(message: WebsocketMessage(_msg)) {
  case message {
    Text(text) -> Ok(text)
    _ -> Error("only text messages are supported")
  }
}

fn parse_message(
  text: String,
  decoder: decode.Decoder(event),
  cb: fn(event) -> Result(t, String),
) -> Result(t, String) {
  let before = timestamp.system_time()

  let parsed =
    json.parse(from: text, using: decoder)
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

pub opaque type Builder(state, event) {
  Builder(
    init: state,
    decoder: decode.Decoder(event),
    on_message: fn(state, event, WebsocketConnection) -> mist.Next(state, event),
  )
}

pub fn new(init: state) -> Builder(state, Nil) {
  Builder(init:, decoder: decode.success(Nil), on_message: fn(state, _, _) {
    mist.continue(state)
  })
}

pub fn message(
  builder: Builder(state, _msg),
  decoder: decode.Decoder(event),
  on_message: fn(state, event, WebsocketConnection) -> mist.Next(state, event),
) -> Builder(state, event) {
  Builder(..builder, decoder:, on_message:)
}

pub fn start(
  builder: Builder(state, event),
  request: request.Request(mist.Connection),
) {
  palabres.info("websocket connection received")
  |> palabres.string(
    "timestamp",
    timestamp.to_rfc3339(timestamp.system_time(), calendar.utc_offset),
  )
  |> palabres.log()

  mist.websocket(
    request: request,
    handler: fn(state, message, conn) {
      let response = {
        use text <- result.try(as_text(message))
        use message <- parse_message(text, builder.decoder)
        Ok(builder.on_message(state, message, conn))
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
    },
    on_init: fn(_conn) { #(builder.init, option.None) },
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
