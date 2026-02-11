use crate::db::TileCategory;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema)]
pub struct Account {
    pub id: String,
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema)]
pub struct Field {
    pub id: i64,
    pub name: String,
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema)]
#[serde(tag = "class")]
pub enum CardType {
    Tile(TileType),
    Citizen(Species),
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema)]
pub struct TileType {
    pub id: String,
    pub card_set_id: String,
    pub category: TileCategory,
    pub houses: i32,
    pub employs: i32,
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema)]
pub struct Species {
    pub id: String,
    pub card_set_id: String,
}
