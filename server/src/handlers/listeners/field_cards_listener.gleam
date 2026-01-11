import db/notification_listener
import db/rows
import dto/output_action
import dto/output_message
import gleam/dynamic/decode
import gleam/int
import gleam/result
import gleam/string
import mist
import models/field_card
import palabres
import pog
import websocket/state.{type State as WebsocketState}

type State {
  State(
    field_id: Int,
    message_id: String,
    conn: mist.WebsocketConnection,
    db: pog.Connection,
  )
}

type Event {
  PlaceCard(target: Int, subject: String)
  UnplaceCard(target: Int, subject: String)
}

fn event_decoder() {
  use event <- decode.field("event", decode.string)
  use target <- decode.field("target", decode.int)
  use subject <- decode.field("subject", decode.string)
  case event {
    "place_card" -> decode.success(PlaceCard(target, subject))
    "unplace_card" -> decode.success(UnplaceCard(target, subject))
    _ -> decode.failure(PlaceCard(target, subject), "field cards event")
  }
}

pub fn start(
  st: WebsocketState,
  conn: mist.WebsocketConnection,
  field_id: Int,
  message_id: String,
) {
  notification_listener.new(State(
    field_id:,
    conn:,
    db: state.db_connection(st),
    message_id:,
  ))
  |> notification_listener.listen_to(
    state.notifications_connection(st),
    "field_cards:" <> int.to_string(field_id),
  )
  |> notification_listener.on_notification(event_decoder(), on_notification)
  |> notification_listener.start()
}

fn push_field_card(state: State, field_card_id: Int) {
  let query =
    pog.query("SELECT * FROM field_cards WHERE card_id = $1")
    |> pog.parameter(pog.int(field_card_id))
    |> pog.returning(field_card.from_sql_row())
  use field_rows <- rows.execute(query, state.db)
  use field <- rows.one(field_rows)
  use Nil <- result.try(
    output_action.FieldCard(field)
    |> output_message.OutputMessage(state.message_id)
    |> output_message.send(state.conn)
    |> result.map_error(rows.HandlerError),
  )
  Ok(Nil)
}

fn on_notification(state: State, event: Event) {
  palabres.info("database fields event received")
  |> palabres.string("event", string.inspect(event))
  |> palabres.log()

  let assert Ok(Nil) = case event {
    PlaceCard(field_card_id, _) -> push_field_card(state, field_card_id)
    UnplaceCard(field_card_id, _) ->
      output_action.FieldCardStub(field_card_id)
      |> output_message.OutputMessage(state.message_id)
      |> output_message.send(state.conn)
      |> result.map_error(rows.HandlerError)
  }
  notification_listener.continue(state)
}
