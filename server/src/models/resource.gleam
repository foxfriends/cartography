import gleam/dynamic/decode
import gleam/json

pub type Resource {
  Resource(id: String)
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.string)
  decode.success(Resource(id:))
}

pub fn to_json(resource: Resource) {
  json.object([
    #("id", json.string(resource.id)),
  ])
}
