import cartography_api/game_state.{type CardId}
import gleam/erlang/process
import gleam/otp/static_supervisor
import pubsub

pub opaque type Bus {
  Bus(card_accounts_channel: process.Name(pubsub.Message(String, CardId)))
}

pub fn supervised() {
  let card_accounts_channel = process.new_name("card_accounts_channel")

  let child_spec =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.add(
      pubsub.new()
      |> pubsub.named(card_accounts_channel)
      |> pubsub.supervised(),
    )
    |> static_supervisor.supervised()

  #(child_spec, Bus(card_accounts_channel:))
}

pub fn notify_card_account(bus: Bus, account_id: String, card_id: CardId) {
  process.named_subject(bus.card_accounts_channel)
  |> pubsub.broadcast(account_id, card_id)
}

pub fn on_card_account(bus: Bus, account_id: String) -> process.Subject(CardId) {
  process.named_subject(bus.card_accounts_channel)
  |> pubsub.subscribe(account_id)
}
