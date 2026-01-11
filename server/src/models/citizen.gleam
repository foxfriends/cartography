import gleam/dynamic/decode
import gleam/json
import gleam/option

pub type Citizen {
  Citizen(
    id: Int,
    account_id: String,
    species_id: String,
    card_id: option.Option(Int),
    name: String,
  )
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.int)
  use account_id <- decode.field(1, decode.string)
  use species_id <- decode.field(2, decode.string)
  use card_id <- decode.field(3, decode.optional(decode.int))
  use name <- decode.field(4, decode.string)
  decode.success(Citizen(id:, account_id:, species_id:, card_id:, name:))
}

pub fn to_json(citizen: Citizen) {
  json.object([
    #("id", json.int(citizen.id)),
    #("account_id", json.string(citizen.account_id)),
    #("species_id", json.string(citizen.species_id)),
    #("card_id", json.nullable(citizen.card_id, json.int)),
    #("name", json.string(citizen.name)),
  ])
}
