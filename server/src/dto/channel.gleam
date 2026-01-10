import gleam/dynamic/decode

pub type Channel {
  Fields
  FieldCards(Int)
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
    "field_cards" -> {
      use field_id <- decode.subfield(["channel", "field_id"], decode.int)
      decode.success(FieldCards(field_id))
    }
    "deck" -> decode.success(Deck)
    _ -> decode.failure(Fields, "valid channel")
  }
}
