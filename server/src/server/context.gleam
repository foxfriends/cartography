import gleam/erlang/process.{type Name}
import pog

pub type Context {
  Context(db: Name(pog.Message))
}
