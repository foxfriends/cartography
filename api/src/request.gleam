import codable
import coder

pub opaque type Request {
  Authenticate(auth_token: String)
  DebugAddCard(card_id: String)
}

pub type Error {
  InvalidTag
}

fn authenticate_coder() -> coder.Coder(Request, Error) {
  coder.map(coder.string, coder.Bijection(from: Authenticate))
}

pub fn coder() -> coder.Coder(Request, Error) {
  coder.enum(InvalidTag)
  |> coder.variant("Authenticate", authenticate_coder())
  |> coder.variant("DebugAddCard", debug_add_card_coder())
  |> coder.encode_with(fn(request) {
    Ok(case request {
      Authenticate(auth_token) ->
        codable.Struct("Authenticate", codable.String(auth_token))
      DebugAddCard(card_id) ->
        codable.Struct("DebugAddCard", codable.String(card_id))
    })
  })
}

pub fn authenticate(auth_token: String) -> Request {
  Authenticate(auth_token)
}

pub fn debug_add_card(card_id: String) -> Request {
  DebugAddCard(card_id)
}
