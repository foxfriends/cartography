import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}

pub fn struct(payload: Json, tag: String) -> Json {
  json.object([
    #("#type", json.string("struct")),
    #("#tag", json.string(tag)),
    #("#payload", payload),
  ])
}

pub fn struct_tag(fallback: t, cb: fn(String) -> Decoder(t)) -> Decoder(t) {
  use ty <- decode.field("#type", decode.string)
  case ty {
    "struct" -> {
      use tag <- decode.field("#tag", decode.string)
      cb(tag)
    }
    _ -> {
      decode.failure(fallback, "struct")
    }
  }
}

pub fn struct_payload(
  decoder: Decoder(f),
  cb: fn(f) -> Decoder(t),
) -> Decoder(t) {
  decode.field("#payload", decoder, cb)
}
