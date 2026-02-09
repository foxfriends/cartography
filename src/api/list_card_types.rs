use dioxus::prelude::*;
use crate::dto::*;

#[post("/api/cardtypes", db: axum::Extension<sqlx::PgPool>)]
pub async fn list_card_types() -> dioxus::Result<Vec<CardType>> {
    let mut conn = db.acquire().await?;

    let tile_types = sqlx::query_as!(
        TileType,
        r#"
            SELECT
                card_types.id,
                card_types.card_set_id,
                tile_types.category AS "category: _",
                tile_types.houses,
                tile_types.employs
            FROM card_types
            INNER JOIN tile_types ON tile_types.id = card_types.id
        "#
    )
    .fetch_all(&mut *conn)
    .await?;

    let species_types = sqlx::query_as!(
        Species,
        r#"
            SELECT card_types.id, card_types.card_set_id
            FROM card_types
            INNER JOIN species ON species.id = card_types.id
        "#
    )
    .fetch_all(&mut *conn)
    .await?;

    Ok(tile_types
        .into_iter()
        .map(CardType::Tile)
        .chain(species_types.into_iter().map(CardType::Citizen))
        .collect())
}
