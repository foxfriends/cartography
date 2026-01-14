import gleam/json

pub type Tile {
  Tile(id: Int, tile_type_id: String, name: String)
}

pub fn to_json(tile: Tile) {
  json.object([
    #("id", json.int(tile.id)),
    #("tile_type_id", json.string(tile.tile_type_id)),
    #("name", json.string(tile.name)),
  ])
}
