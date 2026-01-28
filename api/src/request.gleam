import gleam/dynamic/decode
import gleam/json

pub opaque type Request {
  Authenticate(auth_token: String)
  DebugAddCard(card_id: String)
}

pub fn to_text(request: Request) -> String {
  json.to_string(case request {
    Authenticate(auth_token) ->
      json.object([
        #("#type", json.string("struct")),
        #("#tag", json.string("Authenticate")),
        #("#payload", json.string(auth_token)),
      ])
    DebugAddCard(card_id) ->
      json.object([
        #("#type", json.string("struct")),
        #("#tag", json.string("DebugAddCard")),
        #("#payload", json.string(card_id)),
      ])
  })
}

pub fn from_text(text: String) -> Result(Request, json.DecodeError) {
  json.parse(text, {
    use ty <- decode.field("#type", decode.string)
    case ty {
      "struct" -> {
        use tag <- decode.field("#tag", decode.string)
        case tag {
          "Authenticate" -> {
            use payload <- decode.field("#payload", decode.string)
            decode.success(Authenticate(payload))
          }
          "DebugAddCard" -> {
            use payload <- decode.field("#payload", decode.string)
            decode.success(DebugAddCard(payload))
          }
          _ -> {
            decode.failure(Authenticate(""), "valid #tag")
          }
        }
      }
      _ -> {
        decode.failure(Authenticate(""), "#type == 'struct'")
      }
    }
  })
}

pub type Error {
  InvalidTag
}

pub fn authenticate(auth_token: String) -> Request {
  Authenticate(auth_token)
}

pub fn debug_add_card(card_id: String) -> Request {
  DebugAddCard(card_id)
}
