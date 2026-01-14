import gleam/dynamic/decode

pub type Channel {
  Deck
}

pub fn decode_channel() {
  use name <- decode.then(
    decode.one_of(decode.field("channel", decode.string, decode.success), or: [
      decode.subfield(["channel", "topic"], decode.string, decode.success),
    ]),
  )
  case name {
    "deck" -> decode.success(Deck)
    _ -> decode.failure(Deck, "valid channel")
  }
}
