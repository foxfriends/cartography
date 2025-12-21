import account
import gleam/option
import gleam/result
import gleam/string
import mist
import output_message
import pog
import rows
import websocket_state

pub fn handle(
  state: websocket_state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
  account_id: String,
) -> Result(mist.Next(websocket_state.State, _msg), String) {
  let assert Ok(acc) =
    pog.query(
      "INSERT INTO accounts (id) VALUES ($1) ON CONFLICT DO NOTHING RETURNING *",
    )
    |> pog.parameter(pog.text(account_id))
    |> pog.returning(account.from_sql_row())
    |> pog.execute(pog.named_connection(state.context.db))
  {
    use acc <- rows.one_or_none(acc)
    let assert Ok(acc) = case acc {
      option.Some(acc) -> Ok(acc)
      option.None -> {
        let assert Ok(acc) =
          pog.query("SELECT * FROM accounts WHERE id = $1")
          |> pog.parameter(pog.text(account_id))
          |> pog.returning(account.from_sql_row())
          |> pog.execute(pog.named_connection(state.context.db))
        use acc <- rows.one(acc)
        Ok(acc)
      }
    }

    use _ <- result.map(
      output_message.send(
        output_message.OutputMessage(
          data: output_message.Account(account.Account(id: acc.id)),
          id: message_id,
        ),
        conn,
      )
      |> result.map_error(rows.HandlerError),
    )
    Ok(mist.continue(
      websocket_state.State(..state, account_id: option.Some(account_id)),
    ))
  }
  |> result.map_error(string.inspect)
  |> result.flatten()
}
