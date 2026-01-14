import gleam/json

pub type SpeciesNeed {
  SpeciesNeed(species_id: String, resource_id: String, quantity: Int)
}

pub fn to_json(need: SpeciesNeed) {
  json.object([
    #("species_id", json.string(need.species_id)),
    #("resource_id", json.string(need.resource_id)),
    #("quantity", json.int(need.quantity)),
  ])
}
