import game_state.{type FieldId}
import gleam/dynamic/decode
import gleam/json
import repr
import youid/uuid.{type Uuid}

pub opaque type Message {
  Message(id: Uuid, request: Request)
}

pub fn message(request: Request, id: String) -> Message {
  let assert Ok(id) = uuid.from_string(id)
  Message(id:, request:)
}

pub fn id(message: Message) -> String {
  uuid.to_string(message.id)
}

pub fn request(message: Message) -> Request {
  message.request
}

/// A request is sent from the client to the server.
pub opaque type Request {
  Authenticate(auth_token: String)
  WatchField(field_id: FieldId)
  Unsubscribe
  DebugAddCard(card_id: String)
}

pub fn to_json(message: Message) -> json.Json {
  let Message(id, request) = message
  let request = case request {
    Authenticate(auth_token) ->
      json.string(auth_token)
      |> repr.struct("Authenticate")
    WatchField(field_id) ->
      json.int(field_id.id)
      |> repr.struct("WatchField")
    Unsubscribe -> repr.struct(json.null(), "Unsubscribe")
    DebugAddCard(card_id) ->
      json.string(card_id)
      |> repr.struct("DebugAddCard")
  }
  json.object([#("id", json.string(uuid.to_string(id))), #("request", request)])
}

pub fn to_string(message: Message) -> String {
  message
  |> to_json()
  |> json.to_string()
}

pub fn from_string(string: String) -> Result(Message, json.DecodeError) {
  json.parse(string, {
    use id <- decode.field("id", repr.uuid())
    use request <- decode.field("request", {
      use tag <- repr.struct_tag(Unsubscribe)
      case tag {
        "Authenticate" -> {
          use payload <- repr.struct_payload(decode.string)
          decode.success(Authenticate(payload))
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
          decode.success(DebugAddCard(payload))
        }
        _ -> {
          decode.failure(Unsubscribe, "valid #tag")
        }
      }
    })
    decode.success(Message(id:, request:))
  })
}
