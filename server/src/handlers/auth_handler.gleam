import db/rows
import dto/output_action
import dto/output_message
import gleam/option
import gleam/result
import gleam/string
import mist
import models/account
import pog
import websocket/state

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
  account_id: String,
) -> Result(mist.Next(state.State, _msg), String) {
  let assert Ok(acc) =
    pog.query(
      "INSERT INTO accounts (id) VALUES ($1) ON CONFLICT DO NOTHING RETURNING *",
    )
    |> pog.parameter(pog.text(account_id))
    |> pog.returning(account.from_sql_row())
    |> pog.execute(state.db_connection(st))
  {
    use acc <- rows.one_or_none(acc)
    let assert Ok(acc) = case acc {
      option.Some(acc) -> Ok(acc)
      option.None -> {
        let assert Ok(acc) =
          pog.query("SELECT * FROM accounts WHERE id = $1")
          |> pog.parameter(pog.text(account_id))
          |> pog.returning(account.from_sql_row())
          |> pog.execute(state.db_connection(st))
        use acc <- rows.one(acc)
        Ok(acc)
      }
    }

    use _ <- result.map(
      output_action.Account(account.Account(id: acc.id))
      |> output_message.OutputMessage(id: message_id)
      |> output_message.send(conn)
      |> result.map_error(rows.HandlerError),
    )
    state.authenticate(st, account_id)
    |> mist.continue()
    |> Ok()
  }
  |> result.map_error(string.inspect)
  |> result.flatten()
}
