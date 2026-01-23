pub opaque type Request {
  Authenticate(auth_token: String)
  DebugAddCard(card_id: String)
}

pub fn authenticate(auth_token: String) -> Request {
  Authenticate(auth_token)
}

pub fn debug_add_card(card_id: String) -> Request {
  DebugAddCard(card_id)
}
