use serde::{Deserialize, Serialize};

#[cfg_attr(
    feature = "server",
    derive(sqlx::Type),
    sqlx(type_name = "card_class", rename_all = "lowercase")
)]
#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Copy, Debug)]
pub enum CardClass {
    Tile,
    Citizen,
}

#[cfg_attr(
    feature = "server",
    derive(sqlx::Type),
    sqlx(type_name = "tile_category", rename_all = "lowercase")
)]
#[derive(Serialize, Deserialize, PartialEq, Eq, Hash, Clone, Copy, Debug)]
pub enum TileCategory {
    Residential,
    Production,
    Amenity,
    Source,
    Trade,
    Transportation,
}
