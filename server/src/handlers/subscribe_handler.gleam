import dto/channel
import gleam/result
import mist
import websocket/state

pub fn handle(
  st: state.State,
  _conn: mist.WebsocketConnection,
  message_id: String,
  channel: channel.Channel,
) -> Result(mist.Next(state.State, _msg), String) {
  use _account_id <- state.account_id(st)

  use unsubscribe <- result.try(case channel {
    channel.Deck -> todo
  })

  st
  |> state.add_listener(message_id, unsubscribe)
  |> mist.continue()
  |> Ok()
}
