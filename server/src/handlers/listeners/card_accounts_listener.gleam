import gleam/dynamic/decode
import gleam/string
import mist
import notification_listener
import output_message
import palabres
import pog

type State {
  State(account_id: String, message_id: String, conn: mist.WebsocketConnection)
}

type Event {
  TransferCard(target: Int, subject: String)
}

fn event_decoder() {
  use event <- decode.field("event", decode.string)
  use target <- decode.field("target", decode.int)
  use subject <- decode.field("subject", decode.string)
  case event {
    "transfer_card" -> decode.success(TransferCard(target, subject))
    _ -> decode.failure(TransferCard(target, subject), "card accounts event")
  }
}

pub fn start(
  notifications: pog.NotificationsConnection,
  conn: mist.WebsocketConnection,
  account_id: String,
  message_id: String,
) {
  notification_listener.new(State(account_id:, conn:, message_id:))
  |> notification_listener.listen_to(
    notifications,
    "card_accounts:" <> account_id,
  )
  |> notification_listener.on_notification(event_decoder(), on_notification)
  |> notification_listener.start()
}

fn on_notification(state: State, event: Event) {
  palabres.info("database card accounts event received")
  |> palabres.string("event", string.inspect(event))
  |> palabres.log()

  let assert Ok(Nil) = case event {
    TransferCard(card_id, _) ->
      output_message.CardAccount(card_id)
      |> output_message.OutputMessage(state.message_id)
      |> output_message.send(state.conn)
  }
  notification_listener.continue(state)
}
