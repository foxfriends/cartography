import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/otp/actor
import gleam/otp/supervision
import gleam/string
import palabres
import pog

pub opaque type Listener {
  Dynamic(fn(dynamic.Dynamic) -> Nil)
}

type Subscription {
  Subscription(topic: String, listener: Listener)
}

type State {
  State(connection: pog.Connection, listeners: Dict(String, Subscription))
}

pub opaque type Message {
  Subscribe(String, String, Listener)
  Unsubscribe(String)
}

pub opaque type Config {
  Config(builder: actor.Builder(State, Message, process.Subject(Message)))
}

pub fn new(name: process.Name(Message), connection: pog.Connection) {
  actor.new_with_initialiser(10, fn(_subject) {
    let subject = process.named_subject(name)

    let selector =
      process.new_selector()
      |> process.select(subject)

    State(connection, dict.new())
    |> actor.initialised()
    |> actor.selecting(selector)
    |> actor.returning(subject)
    |> Ok
  })
  |> actor.on_message(on_message)
  |> actor.named(name)
  |> Config
}

pub fn supervised(config: Config) {
  supervision.supervisor(fn() { actor.start(config.builder) })
}

fn on_message(state: State, message: Message) -> actor.Next(State, Message) {
  case message {
    Subscribe(id, topic, listener) -> {
      let assert Ok(_) =
        pog.query("LISTEN " <> escape_ident(topic))
        |> pog.execute(state.connection)
      State(
        ..state,
        listeners: dict.insert(
          state.listeners,
          id,
          Subscription(topic, listener),
        ),
      )
    }
    Unsubscribe(id) -> {
      case dict.get(state.listeners, id) {
        Ok(sub) -> {
          let assert Ok(_) =
            pog.query("UNLISTEN " <> escape_ident(sub.topic))
            |> pog.execute(state.connection)
          Nil
        }
        _ -> Nil
      }
      State(..state, listeners: dict.delete(state.listeners, id))
    }
  }
  |> actor.continue()
}

fn escape_ident(s: String) {
  "\"" <> string.replace(s, "\"", "\"\"") <> "\""
}

pub fn for(listener: Listener, id: String, topic: String) -> Message {
  Subscribe(id, topic, listener)
}

pub fn unsubscribe(id: String) -> Message {
  Unsubscribe(id)
}

pub fn typed(decoder: decode.Decoder(t), handler: fn(t) -> Nil) -> Listener {
  Dynamic(fn(dyn) {
    case decode.run(dyn, decoder) {
      Ok(msg) -> handler(msg)
      Error(error) -> {
        palabres.error("Failed to decode notification")
        |> palabres.string("error", string.inspect(error))
        |> palabres.log()
      }
    }
  })
}

pub fn dynamic(handler: fn(dynamic.Dynamic) -> Nil) -> Listener {
  Dynamic(handler)
}
