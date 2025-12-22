import gleam/erlang/process
import mist
import notifications
import websocket_state

pub fn handle(
  state: websocket_state.State,
  _conn: mist.WebsocketConnection,
  message_id: String,
) -> Result(mist.Next(websocket_state.State, _msg), String) {
  process.named_subject(state.context.notifications)
  |> process.send(notifications.unsubscribe(message_id))

  Ok(mist.continue(state))
}
