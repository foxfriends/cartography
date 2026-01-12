import gleam/dynamic/decode
import gleam/json

pub type TileTypeConsume {
  TileTypeConsume(tile_type_id: String, resource_id: String, quantity: Int)
}

pub fn from_sql_row() {
  use tile_type_id <- decode.field(0, decode.string)
  use resource_id <- decode.field(1, decode.string)
  use quantity <- decode.field(2, decode.int)
  decode.success(TileTypeConsume(tile_type_id:, resource_id:, quantity:))
}

pub fn to_json(consume: TileTypeConsume) {
  json.object([
    #("tile_type_id", json.string(consume.tile_type_id)),
    #("resource_id", json.string(consume.resource_id)),
    #("quantity", json.int(consume.quantity)),
  ])
}
