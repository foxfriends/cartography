use crate::api::errors::internal_server_error;
use crate::dto::*;
use axum::Json;

#[derive(serde::Serialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Deserialize))]
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

#[cfg(test)]
mod tests {
    use crate::test::prelude::*;
    use axum::body::Body;
    use axum::http::Request;
    use sqlx::PgPool;

    use super::ListCardTypesResponse;

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed"))
    )]
    async fn get_banner_ok(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get("/api/v1/cardtypes")
            .body(Body::empty())
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: ListCardTypesResponse = response.json().await.unwrap();
        assert_eq!(response.card_types.len(), 14);
    }
}
