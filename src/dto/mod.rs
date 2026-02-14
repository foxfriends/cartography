use crate::db::TileCategory;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

#[derive(Serialize, Deserialize, ToSchema)]
#[serde(untagged)]
pub enum AccountIdOrMe {
    #[serde(rename = "@me")]
    Me,
    AccountId(String),
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct Account {
    pub id: String,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct Field {
    pub id: i64,
    pub name: String,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
#[serde(tag = "class")]
pub enum CardType {
    Tile(TileType),
    Citizen(Species),
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct TileType {
    pub id: String,
    pub card_set_id: String,
    pub category: TileCategory,
    pub houses: i32,
    pub employs: i32,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct Species {
    pub id: String,
    pub card_set_id: String,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct PackBanner {
    pub id: String,
    pub start_date: OffsetDateTime,
    pub end_date: Option<OffsetDateTime>,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct PackBannerCard {
    pub card_type_id: String,
    pub frequency: u32,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct Pack {
    pub id: i64,
    pub account_id: String,
    pub pack_banner_id: String,
    pub opened_at: Option<OffsetDateTime>,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct Card {
    pub id: i64,
    pub card_type_id: String,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
#[serde(tag = "class")]
#[expect(dead_code)]
pub enum CardData {
    #[serde(rename = "Tile")]
    Tile(Tile),
    #[serde(rename = "Citizen")]
    Citizen(Citizen),
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct Tile {
    pub tile_type_id: String,
    pub name: String,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct Citizen {
    pub species_id: String,
    pub name: String,
}
