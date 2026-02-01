import mist
import websocket/state
import youid/uuid

pub fn handle(
  st: state.State,
  message_id: uuid.Uuid,
) -> Result(mist.Next(state.State, _msg), String) {
  state.unsubscribe(st, message_id)
  |> mist.continue()
  |> Ok()
}
