pub mod deck_state;
pub mod field_state;
pub mod player_socket;

#[derive(Clone, Copy, Debug)]
pub struct Unsubscribe;

#[derive(Clone, Debug)]
pub struct AddCardToDeck {
    pub account_id: String,
    pub card_id: i64,
}
