use crate::api::errors::{ErrorDetailResponse, JsonError, PackNotFoundError};
use crate::api::{errors::internal_server_error, middleware::authorization::Authorization};
use crate::dto::*;
use axum::{Extension, Json, extract::Path};

#[derive(serde::Serialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Deserialize))]
pub struct GetPackResponse {
    pack: Pack,
    pack_cards: Option<Vec<Card>>,
}

#[utoipa::path(
    get,
    path = "/api/v1/packs/{pack_id}",
    description = "Get a pack. The contents of unopened packs cannot be seen.",
    tags = ["Pack", "Player"],
    security(("trust" = [])),
    responses(
        (status = OK, description = "Successfully retrieved pack.", body = GetPackResponse),
        (status = NOT_FOUND, description = "Pack not found, or not your pack.", body = ErrorDetailResponse),
    ),
    params(
        ("pack_id" = i64, Path, description = "The ID of the pack to retrieve.")
    )
)]
pub async fn get_pack(
    db: Extension<sqlx::PgPool>,
    authorization: Extension<Authorization>,
    Path(pack_id): Path<i64>,
) -> axum::response::Result<Json<GetPackResponse>> {
    let account_id = authorization.authorized_account_id()?;
    let mut conn = db.acquire().await.map_err(internal_server_error)?;

    let pack = sqlx::query_as!(
        Pack,
        r#"
            SELECT packs.id, packs.pack_banner_id, packs.opened_at
            FROM packs
            WHERE id = $1 AND account_id = $2
        "#,
        pack_id,
        account_id,
    )
    .fetch_optional(&mut *conn)
    .await
    .map_err(internal_server_error)?
    .ok_or(JsonError(PackNotFoundError { pack_id }))?;

    if pack.opened_at.is_none() {
        return Ok(Json(GetPackResponse {
            pack,
            pack_cards: None,
        }));
    }
    let pack_cards = sqlx::query_as!(
        Card,
        r#"
            SELECT id, card_type_id
            FROM cards
            INNER JOIN pack_contents ON pack_contents.card_id = cards.id
            WHERE pack_contents.pack_id = $1
        "#,
        pack_id,
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(internal_server_error)?;
    Ok(Json(GetPackResponse {
        pack,
        pack_cards: Some(pack_cards),
    }))
}

#[cfg(test)]
mod tests {
    use crate::test::prelude::*;
    use axum::http::{Request, StatusCode};
    use sqlx::PgPool;

    use super::GetPackResponse;

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn get_pack_unopened(pool: PgPool) {
        let pack = sqlx::query!(
            "SELECT id FROM packs WHERE account_id = 'foxfriends' AND opened_at IS NULL"
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get(format!("/api/v1/packs/{}", pack.id))
            .header("Authorization", "Trust foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: GetPackResponse = response.json().await.unwrap();
        assert!(response.pack.opened_at.is_none());
        assert!(response.pack_cards.is_none());
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn get_pack_opened(pool: PgPool) {
        let pack = sqlx::query!(
            "SELECT id FROM packs WHERE account_id = 'foxfriends' AND opened_at IS NOT NULL"
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get(format!("/api/v1/packs/{}", pack.id))
            .header("Authorization", "Trust foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: GetPackResponse = response.json().await.unwrap();
        assert!(response.pack.opened_at.is_some());
        assert!(response.pack_cards.is_some());
        assert_eq!(response.pack_cards.as_ref().unwrap().len(), 5);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("account"))
    )]
    pub fn get_pack_not_found(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get("/api/v1/packs/1")
            .header("Authorization", "Trust foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn get_pack_not_owned(pool: PgPool) {
        let pack = sqlx::query!(
            "SELECT id FROM packs WHERE account_id = 'foxfriends' AND opened_at IS NULL"
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get(format!("/api/v1/packs/{}", pack.id))
            .header("Authorization", "Trust not-foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);
    }
}
