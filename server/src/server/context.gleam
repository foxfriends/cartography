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
