import cartography_api/game_state
import db/rows
import db/sql
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/string
import pog

fn to_tile(tile: sql.GetPlayerDeckRow) -> game_state.Tile {
  case tile {
    sql.GetPlayerDeckRow(
      id,
      name,
      tile_type_id: option.Some(tile_type_id),
      species_id: option.None,
      home_tile_id: option.None,
    ) ->
      game_state.Tile(
        id: game_state.TileId(id),
        tile_type_id: game_state.TileTypeId(tile_type_id),
        name:,
      )
    _ -> panic as "unreachable"
  }
}

fn to_citizen(citizen: sql.GetPlayerDeckRow) -> game_state.Citizen {
  case citizen {
    sql.GetPlayerDeckRow(
      id,
      name,
      tile_type_id: option.None,
      species_id: option.Some(species_id),
      home_tile_id:,
    ) ->
      game_state.Citizen(
        id: game_state.CitizenId(id),
        species_id: game_state.SpeciesId(species_id),
        name:,
        home_tile_id: option.map(home_tile_id, game_state.TileId),
      )
    _ -> panic as "unreachable"
  }
}

fn to_field_tile(tile: sql.GetFieldTilesRow) -> game_state.FieldTile {
  game_state.FieldTile(
    id: game_state.TileId(tile.tile_id),
    x: tile.grid_x,
    y: tile.grid_y,
  )
}

fn to_field_citizen(citizen: sql.GetFieldCitizensRow) -> game_state.FieldCitizen {
  game_state.FieldCitizen(
    id: game_state.CitizenId(citizen.citizen_id),
    x: citizen.grid_x,
    y: citizen.grid_y,
  )
}

pub fn load(db: pog.Connection, field_id: game_state.FieldId) {
  use field <- result.try(
    db
    |> sql.get_field_by_id(field_id.id)
    |> result.map_error(string.inspect),
  )
  use field <- rows.one_or(field, "field not found")
  use #(tiles, citizens) <- result.try(
    sql.get_player_deck(db, field.account_id)
    |> result.map(fn(result) {
      list.partition(result.rows, fn(card) { option.is_some(card.tile_type_id) })
      |> pair.map_first(list.map(_, to_tile))
      |> pair.map_second(list.map(_, to_citizen))
    })
    |> result.map_error(string.inspect),
  )

  use field_tiles <- result.try(
    sql.get_field_tiles(db, field_id.id)
    |> result.map(fn(result) { list.map(result.rows, to_field_tile) })
    |> result.map_error(string.inspect),
  )

  use field_citizens <- result.try(
    sql.get_field_citizens(db, field_id.id)
    |> result.map(fn(result) { list.map(result.rows, to_field_citizen) })
    |> result.map_error(string.inspect),
  )

  Ok(game_state.GameState(
    deck: game_state.Deck(tiles:, citizens:),
    field: game_state.Field(
      name: field.name,
      tiles: field_tiles,
      citizens: field_citizens,
    ),
  ))
}
