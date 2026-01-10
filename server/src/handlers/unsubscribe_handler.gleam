import gleam/dict
import mist
import websocket/state

pub fn handle(
  state: state.State,
  _conn: mist.WebsocketConnection,
  message_id: String,
) -> Result(mist.Next(state.State, _msg), String) {
  case dict.get(state.listeners, message_id) {
    Ok(unsub) -> {
      unsub()
      Ok(mist.continue(state))
    }
    Error(_) -> Ok(mist.continue(state))
  }
}
