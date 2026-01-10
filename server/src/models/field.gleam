import gleam/dynamic/decode
import gleam/json

pub type Field {
  Field(id: Int, name: String, account_id: String)
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.int)
  use name <- decode.field(1, decode.string)
  use account_id <- decode.field(2, decode.string)
  decode.success(Field(id:, name:, account_id:))
}

pub fn to_json(field: Field) {
  json.object([
    #("id", json.int(field.id)),
    #("name", json.string(field.name)),
    #("account_id", json.string(field.account_id)),
  ])
}

pub fn from_json() {
  use id <- decode.field("id", decode.int)
  use name <- decode.field("name", decode.string)
  use account_id <- decode.field("account_id", decode.string)
  decode.success(Field(id:, name:, account_id:))
}
