import account
import gleam/json
import mist

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

pub fn send(message: OutputMessage, conn: mist.WebsocketConnection) {
  let message =
    message
    |> to_json()
    |> json.to_string()
  mist.send_text_frame(conn, message)
}
