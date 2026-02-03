import bus
import cartography_api/game_state
import db/rows
import db/sql
import gleam/result
import gleam/string
import mist
import websocket/state

pub fn handle(
  st: state.State,
  card_type_id: game_state.CardTypeId,
) -> Result(mist.Next(state.State, _msg), String) {
  use account_id <- state.account_id(st)
  {
    let assert Ok(card_type) =
      state.db(st)
      |> sql.get_card_type(card_type_id.id)
    use card_type <- rows.one(card_type)

    use card_id <- result.try(case card_type.class {
      sql.Citizen -> {
        let assert Ok(citizen) =
          state.db(st)
          |> sql.create_citizen(account_id, card_type.id)
        use citizen <- rows.one(citizen)
        Ok(game_state.CitizenId(citizen.card_id))
      }
      sql.Tile -> {
        let assert Ok(tile) =
          state.db(st)
          |> sql.create_tile(account_id, card_type.id)
        use tile <- rows.one(tile)
        Ok(game_state.TileId(tile.card_id))
      }
    })

    state.bus(st)
    |> bus.notify_card_account(account_id, card_id)

    Ok(mist.continue(st))
  }
  |> result.map_error(string.inspect)
}
