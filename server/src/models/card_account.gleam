import gleam/dynamic/decode
import gleam/json

pub type CardAccount {
  CardAccount(card_id: Int, account_id: String)
}

pub fn to_json(field_card: CardAccount) {
  json.object([
    #("card_id", json.int(field_card.card_id)),
    #("account_id", json.string(field_card.account_id)),
  ])
}

pub fn from_json() {
  use card_id <- decode.field("card_id", decode.int)
  use account_id <- decode.field("account_id", decode.string)
  decode.success(CardAccount(card_id:, account_id:))
}
