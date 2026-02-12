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

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema)]
pub struct PackBanner {
    pub id: String,
    pub start_date: OffsetDateTime,
    pub end_date: Option<OffsetDateTime>,
    pub distribution: Vec<PackBannerCard>,
}

#[derive(Serialize, Deserialize, PartialEq, Clone, Debug, ToSchema)]
pub struct PackBannerCard {
    pub card_type_id: String,
    pub frequency: u32,
}
