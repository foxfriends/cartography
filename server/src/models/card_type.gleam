import gleam/json
import models/card_class

pub type CardType {
  CardType(id: String, class: card_class.CardClass)
}

pub fn to_json(card_type: CardType) {
  json.object([
    #("id", json.string(card_type.id)),
    #("class", json.string(card_class.to_string(card_type.class))),
  ])
}
