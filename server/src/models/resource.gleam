import gleam/json

pub type Resource {
  Resource(id: String)
}

pub fn to_json(resource: Resource) {
  json.object([
    #("id", json.string(resource.id)),
  ])
}
