import gleam/dynamic/decode
import gleam/json

pub type Card {
  Card(id: Int, card_type_id: String)
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.int)
  use card_type_id <- decode.field(1, decode.string)
  decode.success(Card(id:, card_type_id:))
}

pub fn to_json(citizen: Card) {
  json.object([
    #("id", json.int(citizen.id)),
    #("card_type_id", json.string(citizen.card_type_id)),
  ])
}
