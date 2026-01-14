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

pub fn to_json(citizen: Citizen) {
  json.object([
    #("id", json.int(citizen.id)),
    #("species_id", json.string(citizen.species_id)),
    #("home_tile_id", json.nullable(citizen.home_tile_id, json.int)),
    #("name", json.string(citizen.name)),
  ])
}
