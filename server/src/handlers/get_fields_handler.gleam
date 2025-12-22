import mist
import models/field
import output_message
import pog
import websocket_state

pub fn handle(
  state: websocket_state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
) -> Result(mist.Next(websocket_state.State, _msg), String) {
  use account_id <- websocket_state.account_id(state)
  let assert Ok(result) =
    pog.query("SELECT * FROM fields WHERE account_id = $1")
    |> pog.parameter(pog.text(account_id))
    |> pog.returning(field.from_sql_row())
    |> pog.execute(pog.named_connection(state.context.db))

  let assert Ok(_) =
    output_message.Fields(result.rows)
    |> output_message.OutputMessage(id: message_id)
    |> output_message.send(conn)

  Ok(mist.continue(state))
}
