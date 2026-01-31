import gleam/dict.{type Dict}
import gleam/erlang/process.{type Down, type Monitor, type Pid, type Subject}
import gleam/option
import gleam/otp/actor
import gleam/otp/supervision
import gleam/result
import gleam/set.{type Set}
import util

pub opaque type Message(channel, message) {
  Subscribe(channel, Subject(message))
  Unsubscribe(Subject(message))
  Hangup(Down)
  Broadcast(channel, message)
  Stop
}

pub type PubSub(channel, message)

type State(channel, message) {
  State(
    channels: Dict(channel, Set(Subject(message))),
    monitors: Dict(Pid, #(Monitor, Set(Subject(message)))),
  )
}

pub fn start(config: Config(channel, message)) {
  actor.new_with_initialiser(10, fn(sub) {
    let selector =
      process.new_selector()
      |> process.select(sub)
      |> process.select_monitors(Hangup)

    actor.initialised(State(channels: dict.new(), monitors: dict.new()))
    |> actor.selecting(selector)
    |> actor.returning(sub)
    |> Ok()
  })
  |> util.with_some(config.name, actor.named)
  |> actor.on_message(on_message)
  |> actor.start()
}

type Name(channel, message) =
  process.Name(Message(channel, message))

pub opaque type Config(channel, message) {
  Config(name: option.Option(Name(channel, message)))
}

pub fn supervised(config: Config(channel, message)) {
  supervision.supervisor(fn() { start(config) })
}

pub fn new() {
  Config(name: option.None)
}

pub fn named(_config: Config(_c, _m), name: Name(channel, message)) {
  Config(name: option.Some(name))
}

fn on_message(
  state: State(channel, message),
  message: Message(channel, message),
) -> actor.Next(State(channel, message), Message(channel, message)) {
  case message {
    Broadcast(channel, message) -> {
      dict.get(state.channels, channel)
      |> result.lazy_unwrap(set.new)
      |> set.each(process.send(_, message))
      actor.continue(state)
    }
    Subscribe(channel, subject) ->
      handle_subscribe(state, channel, subject)
      |> actor.continue()
    Unsubscribe(subject) ->
      handle_unsubscribe(state, subject)
      |> actor.continue()
    Hangup(down) ->
      handle_hangup(state, down)
      |> actor.continue()
    Stop -> actor.stop()
  }
}

fn add_listener(
  state: State(channel, message),
  channel: channel,
  subject: Subject(message),
) {
  let channels =
    state.channels
    |> dict.get(channel)
    |> result.lazy_unwrap(set.new)
    |> set.insert(subject)
    |> dict.insert(state.channels, channel, _)
  State(..state, channels:)
}

fn add_monitor(state: State(channel, message), subject: Subject(message)) {
  let assert Ok(pid) = process.subject_owner(subject)
  let monitors = case dict.get(state.monitors, pid) {
    Ok(#(monitor, subjects)) ->
      dict.insert(state.monitors, pid, #(monitor, set.insert(subjects, subject)))
    Error(Nil) ->
      dict.insert(state.monitors, pid, #(
        process.monitor(pid),
        set.new() |> set.insert(subject),
      ))
  }
  State(..state, monitors:)
}

fn handle_subscribe(
  state: State(channel, message),
  channel: channel,
  subject: Subject(message),
) -> State(channel, message) {
  state
  |> add_listener(channel, subject)
  |> add_monitor(subject)
}

fn remove_listener(state: State(channel, message), subject: Subject(message)) {
  let channels =
    dict.map_values(state.channels, fn(_, subs) { set.delete(subs, subject) })
  State(..state, channels:)
}

fn remove_subject(state: State(channel, message), subject: Subject(message)) {
  let assert Ok(pid) = process.subject_owner(subject)
  {
    use #(monitor, subjects) <- result.map(dict.get(state.monitors, pid))
    let subjects = set.delete(subjects, subject)
    let monitors = case set.is_empty(subjects) {
      True -> {
        process.demonitor_process(monitor)
        dict.delete(state.monitors, pid)
      }
      False -> dict.insert(state.monitors, pid, #(monitor, subjects))
    }
    State(..state, monitors:)
  }
  |> result.unwrap(state)
}

fn handle_unsubscribe(
  state: State(channel, message),
  subject: Subject(message),
) -> State(channel, message) {
  state
  |> remove_listener(subject)
  |> remove_subject(subject)
}

fn remove_monitor(state: State(channel, message), pid: Pid) {
  State(..state, monitors: dict.delete(state.monitors, pid))
}

fn handle_hangup(
  state: State(channel, message),
  down: Down,
) -> State(channel, message) {
  case down {
    process.ProcessDown(monitor, pid, _reason) -> {
      process.demonitor_process(monitor)
      let assert Ok(#(_, subjects)) = dict.get(state.monitors, pid)
      subjects
      |> set.fold(state, remove_listener)
      |> remove_monitor(pid)
    }
    process.PortDown(..) -> panic as "unreachable"
  }
}

pub fn broadcast(
  pubsub: Subject(Message(channel, message)),
  channel: channel,
  message: message,
) {
  process.send(pubsub, Broadcast(channel, message))
}

pub fn subscribe(pubsub: Subject(Message(channel, message)), channel: channel) {
  let subject = process.new_subject()
  process.send(pubsub, Subscribe(channel, subject))
  subject
}

pub fn unsubscribe(
  pubsub: Subject(Message(channel, message)),
  subject: Subject(message),
) {
  process.send(pubsub, Unsubscribe(subject))
}

pub fn stop(pubsub: Subject(Message(channel, message))) {
  process.send(pubsub, Stop)
}
