import account
import gleam/json

pub type OutputMessageData {
  Account(account.Account)
}

pub type OutputMessage {
  OutputMessage(data: OutputMessageData, id: String)
}

pub fn to_json(message: OutputMessage) -> json.Json {
  let #(msg_type, data) = case message.data {
    Account(acc) -> #("account", account.to_json(acc))
  }
  json.object([
    #("type", json.string(msg_type)),
    #("data", data),
    #("id", json.string(message.id)),
  ])
}
