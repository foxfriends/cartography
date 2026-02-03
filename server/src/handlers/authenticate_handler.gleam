import cartography_api/account
import cartography_api/response
import db/rows
import db/sql
import gleam/option
import gleam/result
import gleam/string
import mist
import websocket/state
import youid/uuid

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: uuid.Uuid,
  account_id: String,
) -> Result(mist.Next(state.State, _msg), String) {
  {
    let assert Ok(acc) = sql.create_account(state.db(st), account_id)
    use acc <- rows.one_or_none(acc)
    let assert Ok(account_id) = case acc {
      option.Some(acc) -> Ok(acc.id)
      option.None -> {
        let assert Ok(acc) = sql.get_account(state.db(st), account_id)
        use acc <- rows.one(acc)
        Ok(acc.id)
      }
    }

    let message =
      account.Account(id: account_id)
      |> response.Authenticated()
      |> response.message(message_id, 0)
      |> response.to_string()
    use _ <- result.map(
      mist.send_text_frame(conn, message)
      |> result.map_error(rows.HandlerError),
    )
    state.authenticate(st, account_id)
    |> mist.continue()
    |> Ok()
  }
  |> result.map_error(string.inspect)
  |> result.flatten()
}
