import codable
import coder

pub opaque type Request {
  Authenticate(auth_token: String)
  DebugAddCard(card_id: String)
}

pub type Error {
  InvalidTag
}

pub fn coder() -> coder.Coder(Request, coder.EncoderError(Error), e) {
  coder.enum(InvalidTag)
  |> coder.variant(
    "Authenticate",
    coder.map_encoder(coder.string, Authenticate),
  )
  |> coder.variant(
    "DebugAddCard",
    coder.map_encoder(coder.string, DebugAddCard),
  )
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
