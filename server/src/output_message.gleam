import gleam/json
import mist
import models/account
import models/field
import models/field_card

pub type OutputMessageData {
  Account(account.Account)
  Fields(List(field.Field))
  FieldWithCards(field: field.Field, field_cards: List(field_card.FieldCard))
  Field(field: field.Field)
  CardAccount(card_id: Int)
  FieldCard(field_card.FieldCard)
  FieldCardStub(card_id: Int)
}

pub type OutputMessage {
  OutputMessage(data: OutputMessageData, id: String)
}

pub fn to_json(message: OutputMessage) -> json.Json {
  let #(msg_type, data) = case message.data {
    Account(acc) -> #(
      "account",
      json.object([#("account", account.to_json(acc))]),
    )
    Fields(fields) -> #(
      "fields",
      json.object([#("fields", json.array(fields, field.to_json))]),
    )
    FieldWithCards(field_data, field_cards) -> #(
      "field",
      json.object([
        #("field", field.to_json(field_data)),
        #("field_cards", json.array(field_cards, field_card.to_json)),
      ]),
    )
    Field(field_data) -> #(
      "field",
      json.object([
        #("field", field.to_json(field_data)),
      ]),
    )
    CardAccount(card_id) -> #(
      "card_account",
      json.object([
        #("card", json.object([#("id", json.int(card_id))])),
      ]),
    )
    FieldCardStub(card_id) -> #(
      "field_card",
      json.object([
        #("field_card", json.object([#("id", json.int(card_id))])),
      ]),
    )
    FieldCard(field_card) -> #(
      "field_card",
      json.object([
        #("field_card", field_card.to_json(field_card)),
      ]),
    )
  }
  json.object([
    #("type", json.string(msg_type)),
    #("data", data),
    #("id", json.string(message.id)),
  ])
}

pub fn send(message: OutputMessage, conn: mist.WebsocketConnection) {
  let message =
    message
    |> to_json()
    |> json.to_string()
  mist.send_text_frame(conn, message)
}
