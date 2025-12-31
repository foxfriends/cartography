import gleam/dict
import gleam/io
import gleam/result
import gleam/string
import handlers/listeners/fields_listener
import input_message
import mist
import notification_listener
import websocket_state

pub fn handle(
  state: websocket_state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
  channel: input_message.Channel,
) -> Result(mist.Next(websocket_state.State, _msg), String) {
  use account_id <- websocket_state.account_id(state)

  case channel {
    input_message.Fields -> {
      use listener <- result.try(
        fields_listener.start(
          state.context.notifications,
          conn,
          state.context.db,
          account_id,
          message_id,
        )
        |> result.map_error(string.inspect),
      )

      Ok(mist.continue(
        websocket_state.State(
          ..state,
          listeners: dict.insert(state.listeners, message_id, fn() {
            notification_listener.unlisten(listener.data)
          }),
        ),
      ))
    }
    _ -> {
      io.println(string.inspect(channel))
      Ok(mist.continue(state))
    }
  }
}
