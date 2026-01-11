import gleam/dynamic/decode
import gleam/json
import models/card_category

pub type CardType {
  CardType(
    id: String,
    category: card_category.CardCategory,
    houses: Int,
    employs: Int,
  )
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.string)
  use category <- decode.field(1, card_category.decoder())
  use houses <- decode.field(2, decode.int)
  use employs <- decode.field(3, decode.int)
  decode.success(CardType(id:, category:, houses:, employs:))
}

pub fn to_json(card_type: CardType) {
  json.object([
    #("id", json.string(card_type.id)),
    #("category", json.string(card_category.to_string(card_type.category))),
    #("houses", json.int(card_type.houses)),
    #("employs", json.int(card_type.employs)),
  ])
}
