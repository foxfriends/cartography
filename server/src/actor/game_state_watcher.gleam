import bus
import cartography_api/game_state
import db/game_state as db_game_state
import gleam/erlang/process
import gleam/otp/actor
import gleam/result
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
  case message {
    CardCreated(_card_id) -> {
      // TODO: include the card in the deck?
      actor.continue(state)
    }
    Stop -> actor.stop()
  }
}
