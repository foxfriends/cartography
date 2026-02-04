import bus
import cartography_api/game_state
import db/game_state as db_game_state
import db/rows
import db/sql
import gleam/erlang/process
import gleam/option
import gleam/otp/actor
import gleam/result
import gleam/string
import mist
import pog
import youid/uuid

pub type Init {
  Init(
    conn: mist.WebsocketConnection,
    message_id: uuid.Uuid,
    account_id: String,
    field_id: game_state.FieldId,
  )
}

type State {
  State(
    conn: mist.WebsocketConnection,
    db: process.Name(pog.Message),
    message_id: uuid.Uuid,
    account_id: String,
    field_id: game_state.FieldId,
    game_state: game_state.GameState,
  )
}

pub type Message {
  CardCreated(card_id: game_state.CardId)
  Stop
}

pub fn start(db: process.Name(pog.Message), bus: bus.Bus, init: Init) {
  actor.new_with_initialiser(50, fn(sub) {
    let selector =
      process.new_selector()
      |> process.select(sub)
      |> process.select_map(
        bus.on_card_account(bus, init.account_id),
        CardCreated,
      )

    use game_state <- result.try(db_game_state.load(
      pog.named_connection(db),
      init.field_id,
    ))

    State(
      conn: init.conn,
      field_id: init.field_id,
      message_id: init.message_id,
      account_id: init.account_id,
      db:,
      game_state:,
    )
    |> actor.initialised()
    |> actor.selecting(selector)
    |> actor.returning(sub)
    |> Ok()
  })
  |> actor.on_message(handle_message)
  |> actor.start()
}

fn handle_message(state: State, message: Message) -> actor.Next(State, Message) {
  let result = case message {
    CardCreated(game_state.TileId(tile_id)) -> {
      use tile <- result.try(
        state.db
        |> pog.named_connection()
        |> sql.get_tile(tile_id)
        |> result.map_error(string.inspect),
      )
      use tile <- rows.one_or(tile, "created card (tile) not found")
      state.game_state
      |> add_tile_to_deck(game_state.Tile(
        id: game_state.TileId(tile.id),
        name: tile.name,
        tile_type_id: game_state.TileTypeId(tile.tile_type_id),
      ))
      |> fn(gs) { State(..state, game_state: gs) }
      |> actor.continue()
      |> Ok()
    }
    CardCreated(game_state.CitizenId(citizen_id)) -> {
      use citizen <- result.try(
        state.db
        |> pog.named_connection()
        |> sql.get_citizen(citizen_id)
        |> result.map_error(string.inspect),
      )
      use citizen <- rows.one_or(citizen, "created card (citizen) not found")
      state.game_state
      |> add_citizen_to_deck(game_state.Citizen(
        id: game_state.CitizenId(citizen.id),
        name: citizen.name,
        species_id: game_state.SpeciesId(citizen.species_id),
        home_tile_id: option.map(citizen.home_tile_id, game_state.TileId),
      ))
      |> fn(gs) { State(..state, game_state: gs) }
      |> actor.continue()
      |> Ok()
    }
    Stop -> Ok(actor.stop())
  }

  case result {
    Ok(next) -> next
    Error(error) -> actor.stop_abnormal(error)
  }
}

fn add_tile_to_deck(state: game_state.GameState, tile: game_state.Tile) {
  game_state.GameState(
    ..state,
    deck: game_state.Deck(..state.deck, tiles: [tile, ..state.deck.tiles]),
  )
}

fn add_citizen_to_deck(state: game_state.GameState, citizen: game_state.Citizen) {
  game_state.GameState(
    ..state,
    deck: game_state.Deck(..state.deck, citizens: [
      citizen,
      ..state.deck.citizens
    ]),
  )
}
