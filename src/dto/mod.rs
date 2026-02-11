use crate::db::TileCategory;
use serde::{Deserialize, Serialize};
use ts_rs::TS;
use utoipa::ToSchema;

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema, TS)]
pub struct Account {
    pub id: String,
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema, TS)]
pub struct Field {
    pub id: i64,
    pub name: String,
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema, TS)]
#[serde(tag = "class")]
pub enum CardType {
    Tile(TileType),
    Citizen(Species),
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema, TS)]
pub struct TileType {
    pub id: String,
    pub card_set_id: String,
    pub category: TileCategory,
    pub houses: i32,
    pub employs: i32,
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema, TS)]
pub struct Species {
    pub id: String,
    pub card_set_id: String,
}
