import gleam/erlang/process.{type Name}
import gleam/erlang/reference
import gleam/option.{type Option}
import gleam/otp/actor
import gleam/result
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

pub opaque type Builder(state, msg) {
  Builder(
    initial_state: state,
    channel: Option(#(pog.NotificationsConnection, String)),
    handler: Option(
      fn(State(state), Message(msg)) -> actor.Next(State(state), Message(msg)),
    ),
    name: Option(Name(Message(msg))),
  )
}

pub fn new(state: state) -> Builder(state, msg) {
  Builder(
    initial_state: state,
    channel: option.None,
    handler: option.None,
    name: option.None,
  )
}

pub fn named(
  builder: Builder(state, msg),
  name: Name(Message(msg)),
) -> Builder(state, msg) {
  Builder(..builder, name: option.Some(name))
}

pub fn listen_to(
  builder: Builder(state, msg),
  notifications: pog.NotificationsConnection,
  channel: String,
) -> Builder(state, msg) {
  Builder(..builder, channel: option.Some(#(notifications, channel)))
}

pub fn on_message(
  builder: Builder(state, msg),
  handler: fn(State(state), Message(msg)) ->
    actor.Next(State(state), Message(msg)),
) -> Builder(state, msg) {
  Builder(..builder, handler: option.Some(handler))
}

fn with(state: t, option: Option(v), apply: fn(t, v) -> t) -> t {
  case option {
    option.None -> state
    option.Some(v) -> apply(state, v)
  }
}

pub fn stop(state: State(st)) {
  pog.unlisten(state.notifications, state.reference)
}

pub fn unlisten(listener: process.Subject(Message(msg))) {
  process.send(listener, Unlisten)
}

pub fn start(
  builder: Builder(state, msg),
) -> Result(actor.Started(process.Subject(Message(msg))), actor.StartError) {
  actor.new_with_initialiser(100, fn(subject) -> Result(
    actor.Initialised(State(state), Message(msg), process.Subject(Message(msg))),
    String,
  ) {
    use #(notifications, channel) <- result.try(option.to_result(
      builder.channel,
      "missing channel",
    ))
    let reference = pog.listen(notifications, channel)

    let selector: process.Selector(Message(msg)) =
      process.new_selector()
      |> process.select(subject)
      |> process.merge_selector(
        pog.notification_selector()
        |> process.map_selector(Notification),
      )

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
  |> with(builder.handler, actor.on_message)
  |> actor.start()
}
