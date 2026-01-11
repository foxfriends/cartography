import gleam/dynamic/decode
import gleam/json

pub type Species {
  Species(id: String)
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.string)
  decode.success(Species(id:))
}

pub fn to_json(species: Species) {
  json.object([
    #("id", json.string(species.id)),
  ])
}
