import gleam/dynamic/decode
import gleam/json

pub type Field {
  Field(
    id: Int,
    name: String,
    account_id: String,
    grid_x: Int,
    grid_y: Int,
    width: Int,
    height: Int,
  )
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.int)
  use name <- decode.field(1, decode.string)
  use account_id <- decode.field(2, decode.string)
  use grid_x <- decode.field(3, decode.int)
  use grid_y <- decode.field(4, decode.int)
  use width <- decode.field(5, decode.int)
  use height <- decode.field(6, decode.int)
  decode.success(Field(
    id:,
    name:,
    account_id:,
    grid_x:,
    grid_y:,
    width:,
    height:,
  ))
}

pub fn to_json(field: Field) {
  json.object([
    #("id", json.int(field.id)),
    #("name", json.string(field.name)),
    #("account_id", json.string(field.account_id)),
    #("grid_x", json.int(field.grid_x)),
    #("grid_y", json.int(field.grid_y)),
    #("width", json.int(field.width)),
    #("height", json.int(field.height)),
  ])
}

pub fn from_json() {
  use id <- decode.field("id", decode.int)
  use name <- decode.field("name", decode.string)
  use account_id <- decode.field("account_id", decode.string)
  use grid_x <- decode.field("grid_x", decode.int)
  use grid_y <- decode.field("grid_y", decode.int)
  use width <- decode.field("width", decode.int)
  use height <- decode.field("height", decode.int)
  decode.success(Field(
    id:,
    name:,
    account_id:,
    grid_x:,
    grid_y:,
    width:,
    height:,
  ))
}
