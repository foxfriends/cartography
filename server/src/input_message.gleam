import channel
import gleam/dynamic/decode

pub type MessageData {
  Auth(String)
  GetFields
  GetField(Int)
  Subscribe(channel.Channel)
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
    "subscribe" -> decode.map(channel.decode_channel(), Subscribe)
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
