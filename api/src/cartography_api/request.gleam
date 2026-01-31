import cartography_api/game_state.{type CardTypeId, type FieldId}
import cartography_api/internal/repr
import gleam/dynamic/decode
import gleam/json
import youid/uuid.{type Uuid}

pub type Message {
  Message(id: Uuid, request: Request)
}

pub fn message(request: Request, id: String) -> Message {
  let assert Ok(id) = uuid.from_string(id)
  Message(id:, request:)
}

/// A request is sent from the client to the server.
pub type Request {
  Authenticate(auth_token: String)
  ListFields
  WatchField(field_id: FieldId)
  Unsubscribe
  DebugAddCard(card_id: CardTypeId)
}

pub fn to_json(message: Message) -> json.Json {
  let Message(id, request) = message
  let request = case request {
    Authenticate(auth_token) ->
      json.string(auth_token)
      |> repr.struct("Authenticate")
    ListFields -> repr.struct(json.null(), "ListFields")
    WatchField(field_id) ->
      json.int(field_id.id)
      |> repr.struct("WatchField")
    Unsubscribe -> repr.struct(json.null(), "Unsubscribe")
    DebugAddCard(card_id) ->
      json.string(card_id.id)
      |> repr.struct("DebugAddCard")
  }
  json.object([#("id", json.string(uuid.to_string(id))), #("request", request)])
}

pub fn to_string(message: Message) -> String {
  message
  |> to_json()
  |> json.to_string()
}

pub fn decoder() {
  use id <- decode.field("id", repr.uuid())
  use request <- decode.field("request", {
    use tag <- repr.struct_tag(Unsubscribe)
    case tag {
      "Authenticate" -> {
        use payload <- repr.struct_payload(decode.string)
        decode.success(Authenticate(payload))
      }
      "ListFields" -> {
        decode.success(ListFields)
      }
      "WatchField" -> {
        use payload <- repr.struct_payload(decode.int)
        decode.success(WatchField(game_state.FieldId(payload)))
      }
      "Unsubscribe" -> {
        decode.success(Unsubscribe)
      }
      "DebugAddCard" -> {
        use payload <- repr.struct_payload(decode.string)
        decode.success(DebugAddCard(game_state.CardTypeId(payload)))
      }
      _ -> {
        decode.failure(Unsubscribe, "valid #tag")
      }
    }
  })
  decode.success(Message(id:, request:))
}

pub fn from_string(string: String) -> Result(Message, json.DecodeError) {
  json.parse(string, decoder())
}
