import gleam/erlang/process
import pubsub

type Channel {
  One
  Two
}

pub fn pubsub_received_test() {
  let assert Ok(pubsub_actor) = pubsub.start(pubsub.new())
  let pubsub_subject = pubsub_actor.data

  let subscription = pubsub.subscribe(pubsub_subject, One)

  pubsub.broadcast(pubsub_subject, One, 1)
  pubsub.broadcast(pubsub_subject, Two, 2)

  let assert Ok(1) = process.receive(subscription, 1)
  let assert Error(_) = process.receive(subscription, 1)

  pubsub.stop(pubsub_subject)
}

pub fn pubsub_multiple_test() {
  let assert Ok(pubsub_actor) = pubsub.start(pubsub.new())
  let pubsub_subject = pubsub_actor.data

  let subscription_1 = pubsub.subscribe(pubsub_subject, One)
  let subscription_2 = pubsub.subscribe(pubsub_subject, One)

  pubsub.broadcast(pubsub_subject, One, 1)

  let assert Ok(1) = process.receive(subscription_1, 1)
  let assert Ok(1) = process.receive(subscription_2, 1)

  pubsub.stop(pubsub_subject)
}

pub fn pubsub_unsubscribe_test() {
  let assert Ok(pubsub_actor) = pubsub.start(pubsub.new())
  let pubsub_subject = pubsub_actor.data

  let subscription = pubsub.subscribe(pubsub_subject, One)
  pubsub.broadcast(pubsub_subject, One, 1)
  pubsub.unsubscribe(pubsub_subject, subscription)
  pubsub.broadcast(pubsub_subject, One, 2)

  let assert Ok(1) = process.receive(subscription, 1)
  let assert Error(_) = process.receive(subscription, 1)

  pubsub.stop(pubsub_subject)
}

pub fn pubsub_reunsubscribe_test() {
  let assert Ok(pubsub_actor) = pubsub.start(pubsub.new())
  let pubsub_subject = pubsub_actor.data

  let subscription = pubsub.subscribe(pubsub_subject, One)
  pubsub.unsubscribe(pubsub_subject, subscription)
  pubsub.unsubscribe(pubsub_subject, subscription)

  pubsub.stop(pubsub_subject)
}
