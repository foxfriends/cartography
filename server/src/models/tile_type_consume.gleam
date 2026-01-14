import gleam/json

pub type TileTypeConsume {
  TileTypeConsume(tile_type_id: String, resource_id: String, quantity: Int)
}

pub fn to_json(consume: TileTypeConsume) {
  json.object([
    #("tile_type_id", json.string(consume.tile_type_id)),
    #("resource_id", json.string(consume.resource_id)),
    #("quantity", json.int(consume.quantity)),
  ])
}
