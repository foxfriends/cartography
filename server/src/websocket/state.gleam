import gleam/dict
import gleam/option
import pog
import server/context

pub opaque type State {
  State(
    context: context.Context,
    account_id: option.Option(String),
    listeners: dict.Dict(String, fn() -> Nil),
  )
}

pub fn new(context: context.Context) -> State {
  State(context:, account_id: option.None, listeners: dict.new())
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

pub fn add_listener(
  state: State,
  channel: String,
  unsubscribe: fn() -> Nil,
) -> State {
  State(..state, listeners: dict.insert(state.listeners, channel, unsubscribe))
}

pub fn remove_listener(state: State, channel: String) -> State {
  case dict.get(state.listeners, channel) {
    Ok(unsub) -> unsub()
    Error(Nil) -> Nil
  }
  State(..state, listeners: dict.delete(state.listeners, channel))
}
