import cartography_api/game_state
import gleam/json
import gleam/option

pub fn game_state_round_trip_test() {
  let game_state =
    game_state.GameState(
      deck: game_state.Deck(
        tiles: [
          game_state.Tile(
            id: game_state.TileId(3),
            tile_type_id: game_state.TileTypeId("bakery"),
            name: "Bakery 1",
          ),
          game_state.Tile(
            id: game_state.TileId(4),
            tile_type_id: game_state.TileTypeId("house"),
            name: "House 1",
          ),
        ],
        citizens: [
          game_state.Citizen(
            id: game_state.CitizenId(1),
            species_id: game_state.SpeciesId("cat"),
            name: "Panda",
            home_tile_id: option.None,
          ),
          game_state.Citizen(
            id: game_state.CitizenId(2),
            species_id: game_state.SpeciesId("cat"),
            name: "Natto",
            home_tile_id: option.Some(game_state.TileId(4)),
          ),
        ],
      ),
      field: game_state.Field(
        name: "The Field",
        tiles: [
          game_state.FieldTile(id: game_state.TileId(3), x: 1, y: 1),
          game_state.FieldTile(id: game_state.TileId(4), x: 2, y: 1),
        ],
        citizens: [
          game_state.FieldCitizen(id: game_state.CitizenId(2), x: 2, y: 1),
        ],
      ),
    )

  let json = game_state.to_string(game_state)
  let assert Ok(game_state_again) = json.parse(json, game_state.decoder())

  assert game_state == game_state_again
}
