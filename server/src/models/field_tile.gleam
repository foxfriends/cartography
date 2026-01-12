import gleam/dynamic/decode
import gleam/json

pub type FieldTile {
  FieldTile(
    tile_id: Int,
    account_id: String,
    field_id: Int,
    grid_x: Int,
    grid_y: Int,
  )
}

pub fn from_sql_row() {
  use tile_id <- decode.field(0, decode.int)
  use account_id <- decode.field(1, decode.string)
  use field_id <- decode.field(2, decode.int)
  use grid_x <- decode.field(3, decode.int)
  use grid_y <- decode.field(4, decode.int)
  decode.success(FieldTile(tile_id:, account_id:, field_id:, grid_x:, grid_y:))
}

pub fn to_json(field_tile: FieldTile) {
  json.object([
    #("tile_id", json.int(field_tile.tile_id)),
    #("account_id", json.string(field_tile.account_id)),
    #("field_id", json.int(field_tile.field_id)),
    #("grid_x", json.int(field_tile.grid_x)),
    #("grid_y", json.int(field_tile.grid_y)),
  ])
}

pub fn from_json() {
  use tile_id <- decode.field("tile_id", decode.int)
  use account_id <- decode.field("account_id", decode.string)
  use field_id <- decode.field("field_id", decode.int)
  use grid_x <- decode.field("grid_x", decode.int)
  use grid_y <- decode.field("grid_y", decode.int)
  decode.success(FieldTile(tile_id:, account_id:, field_id:, grid_x:, grid_y:))
}
