import gleam/dynamic/decode

pub type Channel {
  Fields
  FieldCards(String)
  Deck
}

pub type MessageData {
  Auth(String)
  GetFields
  GetField(Int)
  Subscribe(Channel)
  Unsubscribe
}

pub type InputMessage {
  InputMessage(data: MessageData, id: String)
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
    decode.one_of(decode.field("channel", decode.string, decode.success), or: [
      decode.subfield(["channel", "topic"], decode.string, decode.success),
    ]),
  )
  case name {
    "fields" -> decode.success(Fields)
    "field_cards" -> {
      use field_id <- decode.subfield(["channel", "field_id"], decode.string)
      decode.success(FieldCards(field_id))
    }
    "deck" -> decode.success(Deck)
    _ -> decode.failure(Fields, "valid channel")
  }
}

fn decode_data(message_type: String) {
  case message_type {
    "auth" -> {
      use id <- decode.field("id", decode.string)
      decode.success(Auth(id))
    }
    "fields" -> decode_empty(GetFields)
    "get_field" -> {
      use field_id <- decode.field("field_id", decode.int)
      decode.success(GetField(field_id))
    }
    "subscribe" -> decode.map(decode_channel(), Subscribe)
    "unsubscribe" -> decode_empty(Unsubscribe)
    "deck" -> decode_empty(GetFields)
    _ -> decode.failure(GetFields, "known message type")
  }
}

pub fn decoder() {
  use message_type <- decode.field("type", decode.string)
  use id <- decode.field("id", decode.string)
  use data <- decode.field("data", decode_data(message_type))
  decode.success(InputMessage(data, id))
}
