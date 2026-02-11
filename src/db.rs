use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

#[derive(sqlx::Type)]
#[sqlx(type_name = "card_class", rename_all = "lowercase")]
#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Copy, Debug, ToSchema)]
#[expect(dead_code)]
pub enum CardClass {
    Tile,
    Citizen,
}

#[derive(sqlx::Type)]
#[sqlx(type_name = "tile_category", rename_all = "lowercase")]
#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Copy, Debug, ToSchema)]
pub enum TileCategory {
    Residential,
    Production,
    Amenity,
    Source,
    Trade,
    Transportation,
}
