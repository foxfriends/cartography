use crate::api::errors::{
    BannerNotFoundError, ErrorDetailResponse, JsonError, internal_server_error,
};
use crate::api::middleware::authorization::Authorization;
use crate::db::CardClass;
use crate::dto::*;
use axum::extract::Path;
use axum::{Extension, Json};
use rand::distr::weighted::WeightedIndex;
use rand::rngs::Xoshiro256PlusPlus;
use rand::{Rng, RngExt, SeedableRng, rng};

#[derive(serde::Serialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Deserialize))]
pub struct PullBannerResponse {
    pack: Pack,
    pack_cards: Vec<Card>,
}

#[utoipa::path(
    post,
    path = "/api/v1/banners/{banner_id}/pull",
    description = "Get full pack banner details.",
    tag = "Game",
    params(
        ("banner_id" = String, Path, description = "Banner ID"),
    ),
    responses(
        (status = OK, description = "The created pack after pulling the banner.", body = PullBannerResponse),
        (status = NOT_FOUND, description = "Banner was not found", body = ErrorDetailResponse),
    ),
)]
pub async fn pull_banner(
    db: axum::Extension<sqlx::PgPool>,
    Path(banner_id): Path<String>,
    Extension(authorization): Extension<Authorization>,
) -> axum::response::Result<Json<PullBannerResponse>> {
    let account_id = authorization.authorized_account_id()?;

    let mut conn = db.begin().await.map_err(internal_server_error)?;

    let banner = sqlx::query!(
        r#"
            SELECT pack_size
            FROM pack_banners
            WHERE id = $1 AND start_date <= now() AND (end_date IS NULL OR end_date > now())
        "#,
        banner_id
    )
    .fetch_optional(&mut *conn)
    .await
    .map_err(internal_server_error)?
    .ok_or_else(|| {
        JsonError(BannerNotFoundError {
            banner_id: banner_id.clone(),
        })
    })?;

    let pack_banner_cards = sqlx::query!(
        r#"
            SELECT card_type_id, frequency, class AS "class: CardClass"
            FROM pack_banner_cards
            INNER JOIN card_types ON card_types.id = pack_banner_cards.card_type_id
            WHERE pack_banner_cards.pack_banner_id = $1
        "#,
        banner_id
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(internal_server_error)?;

    if pack_banner_cards.is_empty() {
        return Err(JsonError(BannerNotFoundError { banner_id }).into());
    }

    let seed = rng().next_u64();
    let pack_generator = Xoshiro256PlusPlus::seed_from_u64(seed);
    let distribution =
        WeightedIndex::new(pack_banner_cards.iter().map(|card| card.frequency)).unwrap();

    let (tile_types, species): (Vec<_>, Vec<_>) = pack_generator
        .sample_iter(distribution)
        .take(banner.pack_size as usize)
        .map(|index| &pack_banner_cards[index])
        .partition(|card| card.class == CardClass::Tile);
    // TODO[v1]: name generation for these things, for now the name is the ID (i18n-key)
    let tile_type_ids: Vec<_> = tile_types
        .into_iter()
        .map(|card| &card.card_type_id)
        .cloned()
        .collect();
    let species_ids: Vec<_> = species
        .into_iter()
        .map(|card| &card.card_type_id)
        .cloned()
        .collect();

    let pack = sqlx::query!(
        r#"
            WITH inserted_pack AS (
                INSERT INTO packs (account_id, pack_banner_id, seed, algorithm)
                VALUES ($1, $2, $3, 'xoshiro256++')
                RETURNING id, account_id, pack_banner_id, opened_at
            ),

            inserted_tile_cards AS (
                INSERT INTO cards (card_type_id)
                VALUES (UNNEST($4::text []))
                RETURNING *
            ),

            inserted_tiles AS (
                INSERT INTO tiles (id, tile_type_id, name)
                SELECT id, card_type_id, card_type_id
                FROM inserted_tile_cards
                RETURNING id
            ),

            inserted_citizen_cards AS (
                INSERT INTO cards (card_type_id)
                VALUES (UNNEST($5::text []))
                RETURNING *
            ),

            inserted_citizens AS (
                INSERT INTO citizens (id, species_id, name)
                SELECT id, card_type_id, card_type_id
                FROM inserted_citizen_cards
                RETURNING id
            ),

            inserted_cards AS (
                SELECT * FROM inserted_tile_cards
                UNION ALL
                SELECT * FROM inserted_citizen_cards
            ),

            inserted_pack_contents AS (
                INSERT INTO pack_contents (pack_id, "position", card_id)
                SELECT inserted_pack.id, ROW_NUMBER() OVER (), inserted_cards.id
                FROM inserted_pack, inserted_cards
                RETURNING *
            )

            SELECT
                inserted_pack.*,
                JSONB_AGG(
                    JSONB_BUILD_OBJECT(
                        'id', inserted_cards.id,
                        'card_type_id', inserted_cards.card_type_id
                    )
                ) AS "pack_cards: sqlx::types::Json<Vec<Card>>"
            FROM inserted_pack, inserted_cards
            GROUP BY
                inserted_pack.id,
                inserted_pack.account_id,
                inserted_pack.pack_banner_id,
                inserted_pack.opened_at
        "#,
        account_id,
        banner_id,
        seed as i64,
        &tile_type_ids,
        &species_ids,
    )
    .fetch_one(&mut *conn)
    .await
    .map_err(internal_server_error)?;

    conn.commit().await.map_err(internal_server_error)?;

    Ok(Json(PullBannerResponse {
        pack: Pack {
            id: pack.id,
            account_id: pack.account_id,
            pack_banner_id: pack.pack_banner_id,
            opened_at: pack.opened_at,
        },
        pack_cards: pack
            .pack_cards
            .expect("pack cards should have been correct JSON")
            .0,
    }))
}

#[cfg(test)]
mod tests {
    use crate::test::prelude::*;
    use axum::body::Body;
    use axum::http::{Request, StatusCode};
    use sqlx::PgPool;

    use super::PullBannerResponse;

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account"))
    )]
    async fn pull_banner_ok(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/banners/base-standard/pull")
            .header("Authorization", "Trust foxfriends")
            .body(Body::empty())
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: PullBannerResponse = response.json().await.unwrap();
        assert_eq!(response.pack.pack_banner_id, "base-standard");
        assert_eq!(response.pack.account_id, "foxfriends");
        assert_eq!(response.pack.opened_at, None);
        assert_eq!(response.pack_cards.len(), 5);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account"))
    )]
    async fn pull_banner_banner_not_found(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/banners/fake-banner/pull")
            .header("Authorization", "Trust foxfriends")
            .body(Body::empty())
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("future-banner", "account"))
    )]
    async fn pull_banner_future_banner_not_found(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/banners/future-banner/pull")
            .header("Authorization", "Trust foxfriends")
            .body(Body::empty())
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("past-banner", "account"))
    )]
    async fn pull_banner_past_banner_not_found(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/banners/past-banner/pull")
            .header("Authorization", "Trust foxfriends")
            .body(Body::empty())
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("empty-banner", "account"))
    )]
    async fn pull_banner_empty_banner_not_found(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/banners/empty-banner/pull")
            .header("Authorization", "Trust foxfriends")
            .body(Body::empty())
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed"))
    )]
    async fn pull_banner_requires_authorization(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/banners/base-standard/pull")
            .body(Body::empty())
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
    }
}
