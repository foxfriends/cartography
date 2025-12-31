import gleam/dict
import mist
import websocket_state

pub fn handle(
  state: websocket_state.State,
  _conn: mist.WebsocketConnection,
  message_id: String,
) -> Result(mist.Next(websocket_state.State, _msg), String) {
  case dict.get(state.listeners, message_id) {
    Ok(unsub) -> {
      unsub()
      Ok(mist.continue(state))
    }
    Error(_) -> Ok(mist.continue(state))
  }
}
