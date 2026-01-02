import channel
import gleam/dict
import gleam/result
import gleam/string
import handlers/listeners/card_accounts_listener
import handlers/listeners/field_cards_listener
import handlers/listeners/fields_listener
import mist
import notification_listener
import websocket_state

pub fn handle(
  state: websocket_state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
  channel: channel.Channel,
) -> Result(mist.Next(websocket_state.State, _msg), String) {
  use account_id <- websocket_state.account_id(state)
  use unsubscribe <- result.try(case channel {
    channel.Fields -> {
      use listener <- result.map(
        fields_listener.start(
          state.context.notifications,
          conn,
          state.context.db,
          account_id,
          message_id,
        )
        |> result.map_error(string.inspect),
      )
      fn() { notification_listener.unlisten(listener.data) }
    }
    channel.Deck -> {
      use listener <- result.map(
        card_accounts_listener.start(
          state.context.notifications,
          conn,
          account_id,
          message_id,
        )
        |> result.map_error(string.inspect),
      )
      fn() { notification_listener.unlisten(listener.data) }
    }
    channel.FieldCards(field_id) -> {
      use listener <- result.map(
        field_cards_listener.start(
          state.context.notifications,
          conn,
          state.context.db,
          field_id,
          message_id,
        )
        |> result.map_error(string.inspect),
      )
      fn() { notification_listener.unlisten(listener.data) }
    }
  })
  Ok(mist.continue(
    websocket_state.State(
      ..state,
      listeners: dict.insert(state.listeners, message_id, unsubscribe),
    ),
  ))
}
