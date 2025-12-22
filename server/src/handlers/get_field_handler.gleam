import gleam/dynamic/decode
import gleam/result
import gleam/string
import mist
import models/field
import models/field_card
import output_message
import pog
import rows
import websocket_state

pub fn handle(
  state: websocket_state.State,
  conn: mist.WebsocketConnection,
  message_id: String,
  field_id: Int,
) {
  let assert Ok(result) =
    pog.query(
      "SELECT
        to_json(fields.*) AS field,
        json_arrayagg(field_cards.* ABSENT ON NULL) AS field_cards
      FROM fields
      LEFT JOIN field_cards ON field_cards.field_id = fields.id
      WHERE fields.id = $1
      GROUP BY fields.id",
    )
    |> pog.parameter(pog.int(field_id))
    |> pog.returning({
      use field_data <- decode.field(0, rows.json(field.from_json()))
      use field_cards_data <- decode.field(
        1,
        rows.json(decode.list(field_card.from_json())),
      )
      decode.success(#(field_data, field_cards_data))
    })
    |> pog.execute(pog.named_connection(state.context.db))
  {
    use #(field_data, field_cards) <- rows.one(result)

    use _ <- result.map(
      output_message.Field(field: field_data, field_cards:)
      |> output_message.OutputMessage(id: message_id)
      |> output_message.send(conn)
      |> result.map_error(rows.HandlerError),
    )

    Ok(mist.continue(state))
  }
  |> result.map_error(string.inspect)
  |> result.flatten()
}
