import actor/game_state_watcher
import bus
import gleam/dict.{type Dict}
import gleam/option.{type Option}
import pog
import server/context.{type Context}
import youid/uuid.{type Uuid}

pub opaque type State {
  State(
    context: Context,
    account_id: Option(String),
    subscriptions: Dict(Uuid, fn() -> Nil),
  )
}

pub fn new(context: context.Context) -> State {
  State(context:, account_id: option.None, subscriptions: dict.new())
}

pub fn account_id(
  state: State,
  with_account_id: fn(String) -> Result(t, String),
) -> Result(t, String) {
  case state.account_id {
    option.Some(id) -> with_account_id(id)
    option.None -> Error("socket not authenticated")
  }
}

pub fn authenticate(state: State, account_id: String) -> State {
  State(..state, account_id: option.Some(account_id))
}

pub fn db(state: State) -> pog.Connection {
  context.db(state.context)
}

pub fn bus(state: State) -> bus.Bus {
  state.context.bus
}

pub fn add_subscription(state: State, id: Uuid, subscription: fn() -> Nil) {
  State(
    ..state,
    subscriptions: dict.insert(state.subscriptions, id, subscription),
  )
}

pub fn unsubscribe(state: State, id: Uuid) {
  case dict.get(state.subscriptions, id) {
    Ok(sub) -> sub()
    Error(_) -> Nil
  }
  State(..state, subscriptions: dict.delete(state.subscriptions, id))
}

pub fn start_game_state_watcher(state: State, init: game_state_watcher.Init) {
  state.context
  |> context.start_game_state_watcher(init)
}
