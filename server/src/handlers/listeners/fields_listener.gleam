import gleam/dynamic/decode
import gleam/erlang/process
import gleam/json
import gleam/otp/actor
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
  |> notification_listener.on_message(on_message)
  |> notification_listener.start()
}

fn parse_message(
  state: notification_listener.State(State),
  message: notification_listener.Message(Message),
  cb: fn(Event) -> actor.Next(state, msg),
) {
  case message {
    notification_listener.Notification(pog.Notify(_, _, _, payload)) -> {
      case json.parse(payload, using: event_decoder()) {
        Ok(message) -> cb(message)
        Error(_) -> {
          notification_listener.stop(state)
          actor.stop_abnormal("unexpected event")
        }
      }
    }
    notification_listener.Unlisten -> {
      notification_listener.stop(state)
      actor.stop()
    }
    notification_listener.Msg(_) -> {
      panic as "unreachable"
    }
  }
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

fn on_message(
  state: notification_listener.State(State),
  message: notification_listener.Message(Message),
) {
  use message <- parse_message(state, message)
  let assert Ok(Nil) = case message {
    NewField(field_id, _) -> push_field(state.state, field_id)
    EditField(field_id, _) -> push_field(state.state, field_id)
  }
  actor.continue(state)
}
