use serde::{Deserialize, Serialize};
use ts_rs::TS;
use utoipa::ToSchema;

#[derive(sqlx::Type)]
#[sqlx(type_name = "card_class", rename_all = "lowercase")]
#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Copy, Debug, ToSchema, TS)]
pub enum CardClass {
    Tile,
    Citizen,
}

#[derive(sqlx::Type)]
#[sqlx(type_name = "tile_category", rename_all = "lowercase")]
#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Copy, Debug, ToSchema, TS)]
pub enum TileCategory {
    Residential,
    Production,
    Amenity,
    Source,
    Trade,
    Transportation,
}
