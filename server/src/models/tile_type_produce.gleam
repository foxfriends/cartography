import gleam/json

pub type TileTypeProduce {
  TileTypeProduce(tile_type_id: String, resource_id: String, quantity: Int)
}

pub fn to_json(produce: TileTypeProduce) {
  json.object([
    #("tile_type_id", json.string(produce.tile_type_id)),
    #("resource_id", json.string(produce.resource_id)),
    #("quantity", json.int(produce.quantity)),
  ])
}
