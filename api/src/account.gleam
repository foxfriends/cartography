import gleam/dynamic/decode
import gleam/json.{type Json}

pub type Account {
  Account(id: String)
}

pub fn to_json(account: Account) -> Json {
  json.object([#("id", json.string(account.id))])
}

pub fn to_string(account: Account) -> String {
  account
  |> to_json()
  |> json.to_string()
}

pub fn decoder() -> decode.Decoder(Account) {
  use id <- decode.field("id", decode.string)
  decode.success(Account(id:))
}

pub fn from_string(string: String) -> Result(Account, json.DecodeError) {
  json.parse(string, decoder())
}
