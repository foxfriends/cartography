import actor/game_state_watcher
import bus
import cartography_api/game_state
import gleam/dict.{type Dict}
import gleam/option.{type Option}
import gleam/otp/factory_supervisor
import mist
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

pub fn db_connection(state: State) -> pog.Connection {
  pog.named_connection(state.context.db)
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

pub fn start_game_state_watcher(
  state: State,
  conn: mist.WebsocketConnection,
  message_id: Uuid,
  account_id: String,
  field_id: game_state.FieldId,
) {
  state.context.game_state_watchers
  |> factory_supervisor.get_by_name()
  |> factory_supervisor.start_child(game_state_watcher.Init(
    bus: state.context.bus,
    conn:,
    message_id:,
    account_id:,
    field_id:,
  ))
}
