import gleam/dynamic/decode
import gleam/json

pub type Tile {
  Tile(id: Int, tile_type_id: String, name: String)
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.int)
  use tile_type_id <- decode.field(1, decode.string)
  use name <- decode.field(2, decode.string)
  decode.success(Tile(id:, tile_type_id:, name:))
}

pub fn to_json(tile: Tile) {
  json.object([
    #("id", json.int(tile.id)),
    #("tile_type_id", json.string(tile.tile_type_id)),
    #("name", json.string(tile.name)),
  ])
}
