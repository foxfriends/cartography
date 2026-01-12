import gleam/dynamic/decode

pub type Channel {
  Fields
  FieldTiles(Int)
  Deck
}

pub fn decode_channel() {
  use name <- decode.then(
    decode.one_of(decode.field("channel", decode.string, decode.success), or: [
      decode.subfield(["channel", "topic"], decode.string, decode.success),
    ]),
  )
  case name {
    "fields" -> decode.success(Fields)
    "field_tiles" -> {
      use field_id <- decode.subfield(["channel", "field_id"], decode.int)
      decode.success(FieldTiles(field_id))
    }
    "deck" -> decode.success(Deck)
    _ -> decode.failure(Fields, "valid channel")
  }
}
