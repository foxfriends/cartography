use crate::db::TileCategory;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;
use utoipa::ToSchema;

#[derive(PartialEq, Eq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub enum AccountIdOrMe {
    #[serde(rename = "@me")]
    Me,
    #[serde(untagged)]
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
    pub pack_banner_id: String,
    pub opened_at: Option<OffsetDateTime>,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize, ToSchema)]
pub struct Card {
    pub id: i64,
    pub card_type_id: String,
}
