import cartography_api/game_state
import gleam/dynamic/decode
import gleam/json.{type Json}

pub type Field {
  Field(id: game_state.FieldId, name: String)
}

pub fn to_json(field: Field) -> Json {
  json.object([
    #("id", json.int(field.id.id)),
    #("name", json.string(field.name)),
  ])
}

pub fn to_string(field: Field) -> String {
  field
  |> to_json()
  |> json.to_string()
}

pub fn decoder() -> decode.Decoder(Field) {
  use id <- decode.field("id", decode.map(decode.int, game_state.FieldId))
  use name <- decode.field("name", decode.string)
  decode.success(Field(id:, name:))
}

pub fn from_string(string: String) -> Result(Field, json.DecodeError) {
  json.parse(string, decoder())
}
