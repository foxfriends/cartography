import dto/channel
import gleam/dynamic/decode

pub type InputAction {
  Auth(String)
  GetFields
  GetField(Int)
  Subscribe(channel.Channel)
  Unsubscribe
}

fn decode_empty(into: InputAction) {
  use _ <- decode.map(decode.dict(
    decode.failure(0, "empty object"),
    decode.failure(0, "empty object"),
  ))
  into
}

pub fn decoder(message_type: String) {
  case message_type {
    "auth" -> {
      use id <- decode.field("id", decode.string)
      decode.success(Auth(id))
    }
    "get_fields" -> decode_empty(GetFields)
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
