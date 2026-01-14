import db/sql
import dto/output_action
import dto/output_message
import gleam/list
import mist
import models/field
import websocket/state

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
) -> Result(mist.Next(state.State, _msg), String) {
  use account_id <- state.account_id(st)
  let assert Ok(result) =
    sql.list_fields_for_account(state.db_connection(st), account_id)
  let assert Ok(_) =
    result.rows
    |> list.map(field.from_list_fields_for_account)
    |> output_action.Fields()
    |> output_message.OutputMessage(id: message_id)
    |> output_message.send(conn)

  Ok(mist.continue(st))
}
