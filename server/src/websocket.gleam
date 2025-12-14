import context.{type Context}
import gleam/dynamic/decode
import gleam/http/request
import gleam/json
import gleam/option
import gleam/result
import gleam/string
import mist.{type Next, type WebsocketConnection, type WebsocketMessage, Text}

type State {
  State(context: Context, account_id: option.Option(String))
}

type Channel {
  Fields
  FieldCards(String)
  Deck
}

type MessageData {
  Auth(String)
  GetFields
  GetField(String)
  Subscribe(Channel)
  Unsubscribe
}

type Message {
  Message(data: MessageData, id: String)
}

fn as_text(message: WebsocketMessage(_msg)) {
  case message {
    Text(text) -> Ok(text)
    _ -> Error("only text messages are supported")
  }
}

fn decode_empty(into: MessageData) {
  use _ <- decode.map(decode.dict(
    decode.failure(0, "empty object"),
    decode.failure(0, "empty object"),
  ))
  into
}

fn decode_channel() {
  use name <- decode.then(
    decode.one_of(decode.field("topic", decode.string, decode.success), or: [
      decode.string,
    ]),
  )
  case name {
    "fields" -> decode.success(Fields)
    "field_cards" -> {
      use field_id <- decode.field("field_id", decode.string)
      decode.success(FieldCards(field_id))
    }
    "deck" -> decode.success(Deck)
    _ -> decode.failure(Fields, "valid channel")
  }
}

fn decode_data(message_type: String) {
  case message_type {
    "auth" -> {
      use id <- decode.subfield(["data", "id"], decode.string)
      decode.success(Auth(id))
    }
    "fields" -> decode_empty(GetFields)
    "get_field" -> {
      use field_id <- decode.subfield(["data", "field_id"], decode.string)
      decode.success(GetField(field_id))
    }
    "subscribe" -> {
      use channel <- decode.field("data", decode_channel())
      decode.success(Subscribe(channel))
    }
    "unsubscribe" -> decode_empty(Unsubscribe)
    "deck" -> decode_empty(GetFields)
    _ -> decode.failure(GetFields, "known message type")
  }
}

fn message_decoder() {
  use message_type <- decode.field("type", decode.string)
  use id <- decode.field("id", decode.string)
  use data <- decode.field("data", decode_data(message_type))
  decode.success(Message(data, id))
}

fn handle_message(
  state: State,
  message: WebsocketMessage(_msg),
  _connection: WebsocketConnection,
) -> Next(State, _msg) {
  let assert Ok(message) =
    message
    |> as_text()
    |> result.try(fn(s) {
      json.parse(from: s, using: message_decoder())
      |> result.map_error(string.inspect)
    })

  case message.data {
    Auth(id) -> mist.continue(State(..state, account_id: option.Some(id)))
    _ -> mist.stop()
  }
}

pub fn socket_handler(
  request: request.Request(mist.Connection),
  context: Context,
) {
  mist.websocket(
    request: request,
    handler: handle_message,
    on_init: fn(_conn) { #(State(context, option.None), option.None) },
    on_close: fn(_state) { Nil },
  )
}
