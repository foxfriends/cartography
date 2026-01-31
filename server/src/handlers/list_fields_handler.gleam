import cartography_api/field
import cartography_api/game_state
import cartography_api/response
import db/sql
import gleam/list
import gleam/result
import gleam/string
import mist
import websocket/state
import youid/uuid

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: uuid.Uuid,
) -> Result(mist.Next(state.State, _msg), String) {
  use account_id <- state.account_id(st)
  {
    let assert Ok(result) =
      sql.list_fields_for_account(state.db_connection(st), account_id)
    let message =
      result.rows
      |> list.map(fn(row) {
        field.Field(id: game_state.FieldId(row.id), name: row.name)
      })
      |> response.Fields()
      |> response.message(message_id, 0)
      |> response.to_string()
    use _ <- result.try(mist.send_text_frame(conn, message))
    Ok(mist.continue(st))
  }
  |> result.map_error(string.inspect)
}
