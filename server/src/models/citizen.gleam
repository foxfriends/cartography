import gleam/dynamic/decode
import gleam/json
import gleam/option

pub type Citizen {
  Citizen(
    id: Int,
    species_id: String,
    home_tile_id: option.Option(Int),
    name: String,
  )
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.int)
  use species_id <- decode.field(1, decode.string)
  use name <- decode.field(2, decode.string)
  use home_tile_id <- decode.field(3, decode.optional(decode.int))
  decode.success(Citizen(id:, species_id:, home_tile_id:, name:))
}

pub fn to_json(citizen: Citizen) {
  json.object([
    #("id", json.int(citizen.id)),
    #("species_id", json.string(citizen.species_id)),
    #("home_tile_id", json.nullable(citizen.home_tile_id, json.int)),
    #("name", json.string(citizen.name)),
  ])
}
