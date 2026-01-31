import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import youid/uuid.{type Uuid}

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

pub fn uuid() -> Decoder(Uuid) {
  use str <- decode.then(decode.string)
  case uuid.from_string(str) {
    Ok(uuid) -> decode.success(uuid)
    Error(Nil) -> decode.failure(uuid.nil, "uuid")
  }
}
