import gleam/erlang/process.{type Name}
import notifications
import pog

pub type Context {
  Context(db: Name(pog.Message), notifications: Name(notifications.Message))
}
