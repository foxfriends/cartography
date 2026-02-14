use crate::api::errors::internal_server_error;
use crate::dto::*;
use axum::Json;

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct ListCardTypesResponse {
    card_types: Vec<CardType>,
}

#[utoipa::path(
    get,
    path = "/api/v1/cardtypes",
    description = "List all available card types.",
    tag = "Global",
    responses(
        (status = OK, description = "Successfully listed all card types.", body = ListCardTypesResponse),
    ),
)]
pub async fn list_card_types(
    db: axum::Extension<sqlx::PgPool>,
) -> axum::response::Result<Json<ListCardTypesResponse>> {
    let mut conn = db.acquire().await.map_err(internal_server_error)?;

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
    .await
    .map_err(internal_server_error)?;

    let species_types = sqlx::query_as!(
        Species,
        r#"
            SELECT card_types.id, card_types.card_set_id
            FROM card_types
            INNER JOIN species ON species.id = card_types.id
        "#
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(internal_server_error)?;

    let card_types = tile_types
        .into_iter()
        .map(CardType::Tile)
        .chain(species_types.into_iter().map(CardType::Citizen))
        .collect();
    Ok(Json(ListCardTypesResponse { card_types }))
}
