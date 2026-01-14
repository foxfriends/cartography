import db/rows
import db/sql
import dto/output_action
import dto/output_message
import gleam/option
import gleam/result
import gleam/string
import mist
import models/account
import websocket/state

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
  account_id: String,
) -> Result(mist.Next(state.State, _msg), String) {
  {
    let assert Ok(acc) = sql.create_account(state.db_connection(st), account_id)
    use acc <- rows.one_or_none(acc)
    let assert Ok(account_id) = case acc {
      option.Some(acc) -> Ok(acc.id)
      option.None -> {
        let assert Ok(acc) =
          sql.get_account(state.db_connection(st), account_id)
        use acc <- rows.one(acc)
        Ok(acc.id)
      }
    }

    use _ <- result.map(
      output_action.Account(account.Account(id: account_id))
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
