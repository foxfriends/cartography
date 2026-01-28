import gleam/dynamic/decode
import gleam/json
import repr

/// A request is sent from the client to the server.
///
/// A response does not necessarily respond to something, it might just be a pushed notification.
pub opaque type Request {
  Authenticate(auth_token: String)
  DebugAddCard(card_id: String)
}

pub fn to_string(request: Request) -> String {
  json.to_string(case request {
    Authenticate(auth_token) ->
      json.string(auth_token)
      |> repr.struct("Authenticate")
    DebugAddCard(card_id) ->
      json.string(card_id)
      |> repr.struct("DebugAddCard")
  })
}

pub fn from_string(string: String) -> Result(Request, json.DecodeError) {
  json.parse(string, {
    use tag <- repr.struct_tag(Authenticate(""))
    case tag {
      "Authenticate" -> {
        use payload <- repr.struct_payload(decode.string)
        decode.success(Authenticate(payload))
      }
      "DebugAddCard" -> {
        use payload <- repr.struct_payload(decode.string)
        decode.success(DebugAddCard(payload))
      }
      _ -> {
        decode.failure(Authenticate(""), "valid #tag")
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
