import dto/output_action
import dto/output_message
import mist
import models/field
import pog
import websocket/state

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
) -> Result(mist.Next(state.State, _msg), String) {
  use account_id <- state.account_id(st)
  let assert Ok(result) =
    pog.query("SELECT * FROM fields WHERE account_id = $1")
    |> pog.parameter(pog.text(account_id))
    |> pog.returning(field.from_sql_row())
    |> pog.execute(state.db_connection(st))

  let assert Ok(_) =
    output_action.Fields(result.rows)
    |> output_message.OutputMessage(id: message_id)
    |> output_message.send(conn)

  Ok(mist.continue(st))
}
