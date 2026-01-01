import gleam/dynamic/decode
import gleam/erlang/process.{type Name}
import gleam/erlang/reference
import gleam/io
import gleam/json
import gleam/option.{type Option}
import gleam/otp/actor
import gleam/result
import gleam/string
import palabres
import pog

pub type State(st) {
  State(
    state: st,
    reference: reference.Reference,
    notifications: pog.NotificationsConnection,
  )
}

pub type Message(msg) {
  Notification(pog.Notification)
  Unlisten
  Msg(msg)
}

pub type Never

pub opaque type Next(state) {
  Continue(state)
  Stop
  StopAbnormal(String)
}

pub fn continue(state: state) {
  Continue(state)
}

pub fn stop() {
  Stop
}

pub fn stop_abnormal(reason: String) {
  StopAbnormal(reason)
}

pub opaque type Builder(state, event, msg) {
  Builder(
    initial_state: state,
    channel: Option(#(pog.NotificationsConnection, String)),
    handler: Option(fn(state, msg) -> Next(state)),
    event_handler: Option(
      #(decode.Decoder(event), fn(state, event) -> Next(state)),
    ),
    name: Option(Name(Message(msg))),
  )
}

pub fn new(state: state) -> Builder(state, Never, Never) {
  Builder(
    initial_state: state,
    channel: option.None,
    handler: option.None,
    event_handler: option.None,
    name: option.None,
  )
}

pub fn named(
  builder: Builder(state, event, msg),
  name: Name(Message(msg)),
) -> Builder(state, event, msg) {
  Builder(..builder, name: option.Some(name))
}

pub fn listen_to(
  builder: Builder(state, event, msg),
  notifications: pog.NotificationsConnection,
  channel: String,
) -> Builder(state, event, msg) {
  Builder(..builder, channel: option.Some(#(notifications, channel)))
}

pub fn on_message(
  builder: Builder(state, event, _msg),
  handler: fn(state, msg) -> Next(state),
) -> Builder(state, event, msg) {
  Builder(..builder, handler: option.Some(handler))
}

pub fn on_notification(
  builder: Builder(state, _event, msg),
  decoder: decode.Decoder(event),
  handler: fn(state, event) -> Next(state),
) -> Builder(state, event, msg) {
  Builder(..builder, event_handler: option.Some(#(decoder, handler)))
}

fn with(state: t, option: Option(v), apply: fn(t, v) -> t) -> t {
  case option {
    option.None -> state
    option.Some(v) -> apply(state, v)
  }
}

fn shutdown(state: State(st)) {
  pog.unlisten(state.notifications, state.reference)
}

pub fn unlisten(listener: process.Subject(Message(msg))) {
  process.send(listener, Unlisten)
}

pub fn start(
  builder: Builder(state, event, msg),
) -> Result(actor.Started(process.Subject(Message(msg))), actor.StartError) {
  use #(notifications, channel) <- result.try(
    option.to_result(builder.channel, "missing channel")
    |> result.map_error(actor.InitFailed),
  )
  use #(event_decoder, event_handler) <- result.try(
    option.to_result(builder.event_handler, "missing event handler")
    |> result.map_error(actor.InitFailed),
  )

  actor.new_with_initialiser(100, fn(subject) -> Result(
    actor.Initialised(State(state), Message(msg), process.Subject(Message(msg))),
    String,
  ) {
    palabres.info("starting database listener")
    |> palabres.string("channel", channel)
    |> palabres.log()

    use reference <- result.try(
      pog.listen(notifications, channel)
      |> result.map_error(fn(_) { "failed to start listener" }),
    )

    let selector: process.Selector(Message(msg)) =
      process.new_selector()
      |> process.select(subject)
      |> process.merge_selector(
        pog.notification_selector()
        |> process.map_selector(Notification),
      )
      |> process.select_other(fn(dyn) {
        io.println(string.inspect(dyn))
        Unlisten
      })

    Ok(
      actor.initialised(State(
        state: builder.initial_state,
        reference:,
        notifications:,
      ))
      |> actor.returning(subject)
      |> actor.selecting(selector),
    )
  })
  |> with(builder.name, actor.named)
  |> actor.on_message(fn(state, message) {
    use delegate_message <- handle_generic(state, message, event_decoder)
    let sub_next = case delegate_message {
      Event(event) -> event_handler(state.state, event)
      Message(msg) -> {
        let assert option.Some(handler) = builder.handler
        handler(state.state, msg)
      }
    }
    case sub_next {
      Stop -> {
        shutdown(state)
        actor.stop()
      }
      StopAbnormal(reason) -> {
        shutdown(state)
        actor.stop_abnormal(reason)
      }
      Continue(substate) -> actor.continue(State(..state, state: substate))
    }
  })
  |> actor.start()
}

fn handle_generic(
  state: State(state),
  message: Message(msg),
  decoder: decode.Decoder(event),
  delegate_fn: fn(DelegateMessage(event, msg)) ->
    actor.Next(State(state), Message(msg)),
) {
  case message {
    Notification(pog.Notify(_, _, channel, payload)) -> {
      palabres.debug("database notification received")
      |> palabres.string("channel", channel)
      |> palabres.string("payload", payload)
      |> palabres.log()

      case json.parse(payload, using: decoder) {
        Ok(event) -> delegate_fn(Event(event))
        Error(_) -> {
          shutdown(state)
          actor.stop_abnormal("unexpected event")
        }
      }
    }
    Unlisten -> {
      shutdown(state)
      actor.stop()
    }
    Msg(msg) -> delegate_fn(Message(msg))
  }
}

type DelegateMessage(event, message) {
  Event(event)
  Message(message)
}
