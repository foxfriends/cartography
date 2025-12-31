import context
import gleam/dict
import gleam/option

pub type State {
  State(
    context: context.Context,
    account_id: option.Option(String),
    listeners: dict.Dict(String, fn() -> Nil),
  )
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
