import gleam/dynamic/decode
import gleam/erlang/process
import gleam/result
import mist
import models/field
import notification_listener
import output_message
import pog
import rows

pub type Message {
  Unlisten
}

type State {
  State(
    account_id: String,
    message_id: String,
    conn: mist.WebsocketConnection,
    db: process.Name(pog.Message),
  )
}

type Event {
  NewField(target: Int, subject: String)
  EditField(target: Int, subject: String)
}

fn event_decoder() {
  use event <- decode.field("event", decode.string)
  use target <- decode.field("target", decode.int)
  use subject <- decode.field("subject", decode.string)
  case event {
    "new_field" -> decode.success(NewField(target, subject))
    "edit_field" -> decode.success(EditField(target, subject))
    _ -> decode.failure(NewField(target, subject), "fields event")
  }
}

pub fn start(
  notifications: pog.NotificationsConnection,
  conn: mist.WebsocketConnection,
  db: process.Name(pog.Message),
  account_id: String,
  message_id: String,
) {
  notification_listener.new(State(account_id:, conn:, db:, message_id:))
  |> notification_listener.listen_to(notifications, "fields:" <> account_id)
  |> notification_listener.on_notification(event_decoder(), on_notification)
  |> notification_listener.start()
}

fn push_field(state: State, field_id: Int) {
  let query =
    pog.query("SELECT * FROM fields WHERE id = $1")
    |> pog.parameter(pog.int(field_id))
    |> pog.returning(field.from_sql_row())
  use field_rows <- rows.execute(query, pog.named_connection(state.db))
  use field <- rows.one(field_rows)
  use Nil <- result.try(
    output_message.Field(field)
    |> output_message.OutputMessage(state.message_id)
    |> output_message.send(state.conn)
    |> result.map_error(rows.HandlerError),
  )
  Ok(Nil)
}

fn on_notification(state: State, event: Event) {
  let assert Ok(Nil) = case event {
    NewField(field_id, _) -> push_field(state, field_id)
    EditField(field_id, _) -> push_field(state, field_id)
  }
  notification_listener.continue(state)
}
