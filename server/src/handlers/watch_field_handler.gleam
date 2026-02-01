import actor/game_state_watcher
import cartography_api/game_state
import gleam/erlang/process
import gleam/result
import gleam/string
import mist
import websocket/state
import youid/uuid

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: uuid.Uuid,
  field_id: game_state.FieldId,
) -> Result(mist.Next(state.State, _msg), String) {
  use account_id <- state.account_id(st)
  {
    use field_watcher <- result.try(state.start_game_state_watcher(
      st,
      conn,
      message_id,
      account_id,
      field_id,
    ))

    st
    |> state.add_subscription(message_id, fn() {
      process.send(field_watcher.data, game_state_watcher.Stop)
    })
    |> mist.continue()
    |> Ok()
  }
  |> result.map_error(string.inspect)
}
