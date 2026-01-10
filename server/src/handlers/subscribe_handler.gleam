import dto/channel
import gleam/dict
import gleam/result
import gleam/string
import handlers/listeners/card_accounts_listener
import handlers/listeners/field_cards_listener
import handlers/listeners/fields_listener
import mist
import notification_listener
import websocket/state

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
  channel: channel.Channel,
) -> Result(mist.Next(state.State, _msg), String) {
  use account_id <- state.account_id(st)
  use unsubscribe <- result.try(case channel {
    channel.Fields -> {
      use listener <- result.map(
        fields_listener.start(
          st.context.notifications,
          conn,
          st.context.db,
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
          st.context.notifications,
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
          st.context.notifications,
          conn,
          st.context.db,
          field_id,
          message_id,
        )
        |> result.map_error(string.inspect),
      )
      fn() { notification_listener.unlisten(listener.data) }
    }
  })
  Ok(mist.continue(
    state.State(
      ..st,
      listeners: dict.insert(st.listeners, message_id, unsubscribe),
    ),
  ))
}
