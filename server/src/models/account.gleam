import gleam/dynamic/decode
import gleam/json

pub type Account {
  Account(id: String)
}

pub fn from_sql_row() {
  use id <- decode.field(0, decode.string)
  decode.success(Account(id:))
}

pub fn to_json(account: Account) {
  json.object([#("id", json.string(account.id))])
}
