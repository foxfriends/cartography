import db/sql
import gleam/dynamic/decode
import gleam/json

pub type Field {
  Field(id: Int, name: String, account_id: String)
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

pub fn from_list_fields_for_account(row: sql.ListFieldsForAccountRow) {
  Field(id: row.id, name: row.name, account_id: row.account_id)
}

pub fn from_get_field_by_id(row: sql.GetFieldByIdRow) {
  Field(id: row.id, name: row.name, account_id: row.account_id)
}
