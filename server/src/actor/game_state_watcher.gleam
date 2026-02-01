import bus
import cartography_api/game_state
import gleam/erlang/process
import gleam/otp/actor
import mist
import youid/uuid

pub type Init {
  Init(
    bus: bus.Bus,
    conn: mist.WebsocketConnection,
    message_id: uuid.Uuid,
    account_id: String,
    field_id: game_state.FieldId,
  )
}

type State {
  State(init: Init, game_state: game_state.GameState)
}

pub type Message {
  CardCreated(card_id: game_state.CardId)
  Stop
}

pub fn start(init: Init) {
  actor.new_with_initialiser(50, fn(sub) {
    let selector =
      process.new_selector()
      |> process.select(sub)
      |> process.select_map(
        bus.on_card_account(init.bus, init.account_id),
        CardCreated,
      )
    State(init:, game_state: game_state.new())
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
