import gleam/dynamic
import gleam/erlang/process
import gleam/io
import gleam/string
import input_message
import mist
import notifications
import websocket_state

pub fn handle(
  state: websocket_state.State,
  _conn: mist.WebsocketConnection,
  message_id: String,
  channel: input_message.Channel,
) -> Result(mist.Next(websocket_state.State, _msg), String) {
  use account_id <- websocket_state.account_id(state)

  case channel {
    input_message.Fields -> {
      process.named_subject(state.context.notifications)
      |> process.send(
        notifications.dynamic(log_notification)
        |> notifications.for(message_id, "fields:" <> account_id),
      )
    }
    _ -> {
      io.println(string.inspect(channel))
    }
  }
  Ok(mist.continue(state))
}

fn log_notification(dyn: dynamic.Dynamic) {
  io.println(string.inspect(dyn))
}
