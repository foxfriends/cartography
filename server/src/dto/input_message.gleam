import dto/input_action
import gleam/dynamic/decode

pub type InputMessage {
  InputMessage(data: input_action.InputAction, id: String)
}

pub fn decoder() {
  use message_type <- decode.field("type", decode.string)
  use id <- decode.field("id", decode.string)
  use data <- decode.field("data", input_action.decoder(message_type))
  decode.success(InputMessage(data, id))
}
