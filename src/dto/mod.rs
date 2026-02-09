use crate::db::TileCategory;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, PartialEq, Clone)]
#[serde(tag = "class")]
pub enum CardType {
    Tile(TileType),
    Citizen(Species),
}

#[derive(Serialize, Deserialize, PartialEq, Clone)]
pub struct TileType {
    pub id: String,
    pub card_set_id: String,
    pub category: TileCategory,
    pub houses: i32,
    pub employs: i32,
}

#[derive(Serialize, Deserialize, PartialEq, Clone)]
pub struct Species {
    pub id: String,
    pub card_set_id: String,
}
