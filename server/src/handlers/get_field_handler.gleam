import db/rows
import db/sql
import dto/output_action
import dto/output_message
import gleam/dynamic/decode
import gleam/json
import gleam/result
import gleam/string
import mist
import models/field
import models/field_tile
import websocket/state

pub fn handle(
  st: state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
  field_id: Int,
) {
  {
    let assert Ok(result) =
      sql.get_field_and_tiles_by_id(state.db_connection(st), field_id)
    use sql.GetFieldAndTilesByIdRow(field_json, field_tiles_json) <- rows.one(
      result,
    )
    let assert Ok(field_data) = json.parse(field_json, field.from_json())
    let assert Ok(field_tiles) =
      json.parse(field_tiles_json, decode.list(field_tile.from_json()))
    use _ <- result.map(
      output_action.FieldWithTiles(field: field_data, field_tiles:)
      |> output_message.OutputMessage(id: message_id)
      |> output_message.send(conn)
      |> result.map_error(rows.HandlerError),
    )

    Ok(mist.continue(st))
  }
  |> result.map_error(string.inspect)
  |> result.flatten()
}
