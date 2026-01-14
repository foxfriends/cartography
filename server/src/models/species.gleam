import gleam/json

pub type Species {
  Species(id: String)
}

pub fn to_json(species: Species) {
  json.object([
    #("id", json.string(species.id)),
  ])
}
