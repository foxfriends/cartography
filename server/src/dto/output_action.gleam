import gleam/json
import models/account
import models/field
import models/field_tile

pub type OutputAction {
  Account(account.Account)
  Fields(List(field.Field))
  FieldWithTiles(field: field.Field, field_tiles: List(field_tile.FieldTile))
  Field(field: field.Field)
  CardAccount(card_id: Int)
  FieldTile(field_tile.FieldTile)
  FieldTileStub(card_id: Int)
}

pub fn to_json(message: OutputAction) -> #(String, json.Json) {
  case message {
    Account(acc) -> #(
      "account",
      json.object([#("account", account.to_json(acc))]),
    )
    Fields(fields) -> #(
      "fields",
      json.object([#("fields", json.array(fields, field.to_json))]),
    )
    FieldWithTiles(field_data, field_tiles) -> #(
      "field",
      json.object([
        #("field", field.to_json(field_data)),
        #("field_tiles", json.array(field_tiles, field_tile.to_json)),
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
    FieldTileStub(card_id) -> #(
      "field_tile",
      json.object([
        #("field_tile", json.object([#("id", json.int(card_id))])),
      ]),
    )
    FieldTile(field_tile) -> #(
      "field_tile",
      json.object([
        #("field_tile", field_tile.to_json(field_tile)),
      ]),
    )
  }
}
