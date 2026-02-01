import cartography_api/internal/repr
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import squirtle

/// Defines a shared game state data model, which the server manages on behalf of a client
/// as a definitive source of truth.
pub type GameState {
  GameState(deck: Deck, field: Field)
}

pub type CardId {
  TileId(id: Int)
  CitizenId(id: Int)
}

pub type CardTypeId {
  CardTypeId(id: String)
  TileTypeId(id: String)
  SpeciesId(id: String)
}

pub type FieldId {
  FieldId(id: Int)
}

pub type Deck {
  Deck(cards: List(Card))
}

pub type Card {
  Tile(id: CardId, tile_type_id: CardTypeId, name: String)
  Citizen(
    id: CardId,
    species_id: CardTypeId,
    name: String,
    home_tile_id: Option(CardId),
  )
}

pub type Field {
  Field(tiles: List(FieldTile), citizens: List(FieldCitizen))
}

pub type FieldTile {
  FieldTile(id: CardId, x: Int, y: Int)
}

pub type FieldCitizen {
  FieldCitizen(id: CardId, x: Int, y: Int)
}

pub fn new() {
  GameState(deck: Deck(cards: []), field: Field(tiles: [], citizens: []))
}

pub fn to_json(game_state: GameState) -> Json {
  json.object([
    #(
      "deck",
      json.object([
        #(
          "cards",
          game_state.deck.cards
            |> list.map(fn(card) {
              case card {
                Tile(TileId(id), TileTypeId(tile_type_id), name) ->
                  json.object([
                    #("id", json.int(id)),
                    #("tile_type_id", json.string(tile_type_id)),
                    #("name", json.string(name)),
                  ])
                  |> repr.struct("Tile")
                Citizen(
                  CitizenId(id),
                  SpeciesId(species_id),
                  name,
                  home_tile_id,
                ) ->
                  json.object([
                    #("id", json.int(id)),
                    #("species_id", json.string(species_id)),
                    #("name", json.string(name)),
                    #(
                      "home_tile_id",
                      json.nullable(home_tile_id, fn(id) { json.int(id.id) }),
                    ),
                  ])
                  |> repr.struct("Citizen")
                _ -> panic as "unreachable"
              }
            })
            |> json.preprocessed_array(),
        ),
      ]),
    ),
    #(
      "field",
      json.object([
        #(
          "tiles",
          game_state.field.tiles
            |> list.map(fn(tile) {
              json.object([
                #("id", json.int(tile.id.id)),
                #("x", json.int(tile.x)),
                #("y", json.int(tile.y)),
              ])
            })
            |> json.preprocessed_array(),
        ),
        #(
          "citizens",
          game_state.field.citizens
            |> list.map(fn(citizen) {
              json.object([
                #("id", json.int(citizen.id.id)),
                #("x", json.int(citizen.x)),
                #("y", json.int(citizen.y)),
              ])
            })
            |> json.preprocessed_array(),
        ),
      ]),
    ),
  ])
}

pub fn to_string(game_state: GameState) -> String {
  game_state
  |> to_json()
  |> json.to_string()
}

pub fn decoder() -> decode.Decoder(GameState) {
  use deck <- decode.field("deck", {
    use cards <- decode.field(
      "cards",
      decode.list({
        use tag <- repr.struct_tag(Tile(
          id: TileId(0),
          tile_type_id: TileTypeId(""),
          name: "",
        ))
        case tag {
          "Tile" -> {
            use id <- decode.field("id", decode.map(decode.int, TileId))
            use tile_type_id <- decode.field(
              "tile_type_id",
              decode.map(decode.string, TileTypeId),
            )
            use name <- decode.field("name", decode.string)
            decode.success(Tile(id:, tile_type_id:, name:))
          }
          "Citizen" -> {
            use id <- decode.field("id", decode.map(decode.int, CitizenId))
            use species_id <- decode.field(
              "species_id",
              decode.map(decode.string, SpeciesId),
            )
            use name <- decode.field("name", decode.string)
            use home_tile_id <- decode.field(
              "home_tile_id",
              decode.optional(decode.map(decode.int, TileId)),
            )
            decode.success(Citizen(id:, species_id:, name:, home_tile_id:))
          }
          _ -> {
            decode.failure(
              Tile(id: TileId(0), tile_type_id: TileTypeId(""), name: ""),
              "card",
            )
          }
        }
      }),
    )
    decode.success(Deck(cards:))
  })
  use field <- decode.field("field", {
    use tiles <- decode.field(
      "tiles",
      decode.list({
        use id <- decode.field("id", decode.map(decode.int, TileId))
        use x <- decode.field("x", decode.int)
        use y <- decode.field("y", decode.int)
        decode.success(FieldTile(id:, x:, y:))
      }),
    )
    use citizens <- decode.field(
      "citizens",
      decode.list({
        use id <- decode.field("id", decode.map(decode.int, CitizenId))
        use x <- decode.field("x", decode.int)
        use y <- decode.field("y", decode.int)
        decode.success(FieldCitizen(id:, x:, y:))
      }),
    )
    decode.success(Field(tiles:, citizens:))
  })
  decode.success(GameState(deck:, field:))
}

pub fn diff(previous: GameState, next: GameState) -> List(squirtle.Patch) {
  let assert Ok(previous) =
    previous
    |> to_string()
    |> squirtle.json_value_parse()
  let assert Ok(next) =
    next
    |> to_string()
    |> squirtle.json_value_parse()
  squirtle.diff(previous, next)
}

pub fn patch(
  previous: GameState,
  patches: List(squirtle.Patch),
) -> Result(GameState, List(decode.DecodeError)) {
  let assert Ok(previous) =
    previous
    |> to_string()
    |> squirtle.json_value_parse()
  let assert Ok(next) =
    // NOTE: this one might fail if the patches are bad, should handle that better,
    // but realistically if there are bad patches, it means we have lost the server.
    previous
    |> squirtle.patch(patches)
  squirtle.json_value_decode(next, decoder())
}
