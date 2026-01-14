import gleam/json

pub type Card {
  Card(id: Int, card_type_id: String)
}

pub fn to_json(citizen: Card) {
  json.object([
    #("id", json.int(citizen.id)),
    #("card_type_id", json.string(citizen.card_type_id)),
  ])
}
