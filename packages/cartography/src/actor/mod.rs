pub mod field_state;
pub mod player_socket;

#[derive(Clone, Copy, Debug)]
pub struct Unsubscribe;

#[derive(Clone, Debug)]
#[expect(dead_code, reason = "stub for later")]
pub struct AddCardToDeck {
    pub account_id: String,
    pub card_id: i64,
}
