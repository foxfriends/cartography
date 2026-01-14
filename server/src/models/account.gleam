import gleam/json

pub type Account {
  Account(id: String)
}

pub fn to_json(account: Account) {
  json.object([#("id", json.string(account.id))])
}
