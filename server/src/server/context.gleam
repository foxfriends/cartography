import actor/game_state_watcher
import bus
import gleam/erlang/process.{type Name, type Subject}
import gleam/otp/factory_supervisor
import pog

pub type Context {
  Context(
    db: Name(pog.Message),
    bus: bus.Bus,
    game_state_watchers: Name(
      factory_supervisor.Message(
        game_state_watcher.Init,
        Subject(game_state_watcher.Message),
      ),
    ),
  )
}

pub fn db(ctx: Context) -> pog.Connection {
  pog.named_connection(ctx.db)
}

pub fn start_game_state_watcher(ctx: Context, init: game_state_watcher.Init) {
  ctx.game_state_watchers
  |> factory_supervisor.get_by_name()
  |> factory_supervisor.start_child(init)
}
