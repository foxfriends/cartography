import dto/output_action
import gleam/json
import mist

pub type OutputMessage {
  OutputMessage(data: output_action.OutputAction, id: String)
}

pub fn to_json(message: OutputMessage) -> json.Json {
  let #(msg_type, data) = output_action.to_json(message.data)
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
