import mist
import websocket/state

pub fn handle(
  st: state.State,
  _conn: mist.WebsocketConnection,
  message_id: String,
) -> Result(mist.Next(state.State, _msg), String) {
  st
  |> state.remove_listener(message_id)
  |> mist.continue()
  |> Ok()
}
