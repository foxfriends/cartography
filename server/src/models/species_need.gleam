import gleam/dynamic/decode
import gleam/json

pub type SpeciesNeed {
  SpeciesNeed(species_id: String, resource_id: String, quantity: Int)
}

pub fn from_sql_row() {
  use species_id <- decode.field(0, decode.string)
  use resource_id <- decode.field(1, decode.string)
  use quantity <- decode.field(2, decode.int)
  decode.success(SpeciesNeed(species_id:, resource_id:, quantity:))
}

pub fn to_json(need: SpeciesNeed) {
  json.object([
    #("species_id", json.string(need.species_id)),
    #("resource_id", json.string(need.resource_id)),
    #("quantity", json.int(need.quantity)),
  ])
}
