use crate::api::errors::{
    BannerNotFoundError, ErrorDetailResponse, JsonError, internal_server_error,
};
use crate::dto::*;
use axum::Json;
use axum::extract::Path;

#[derive(serde::Serialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Deserialize))]
pub struct GetBannerResponse {
    banner: PackBanner,
    banner_cards: Vec<PackBannerCard>,
}

#[utoipa::path(
    get,
    path = "/api/v1/banners/{banner_id}",
    description = "Get full pack banner details.",
    tag = "Global",
    params(
        ("banner_id" = String, Path, description = "Banner ID"),
    ),
    responses(
        (status = OK, description = "Successfully retrieved banner", body = GetBannerResponse),
        (status = NOT_FOUND, description = "Banner was not found", body = ErrorDetailResponse),
    ),
)]
pub async fn get_banner(
    db: axum::Extension<sqlx::PgPool>,
    Path(banner_id): Path<String>,
) -> axum::response::Result<Json<GetBannerResponse>> {
    let mut conn = db.acquire().await.map_err(internal_server_error)?;

    let row = sqlx::query!(
        r#"
            SELECT
                pack_banners.id,
                start_date,
                end_date,
                COALESCE(
                    JSONB_AGG(
                        JSONB_BUILD_OBJECT(
                            'card_type_id',
                            card_type_id,
                            'frequency',
                            frequency
                        )
                    )
                    FILTER
                    (WHERE pack_banner_cards IS NOT NULL),
                    '[]'::jsonb
                ) AS "distribution: sqlx::types::Json<Vec<PackBannerCard>>"
            FROM pack_banners
            LEFT JOIN
                pack_banner_cards
                ON pack_banner_cards.pack_banner_id = pack_banners.id
            WHERE id = $1
            GROUP BY id
        "#,
        banner_id
    )
    .fetch_optional(&mut *conn)
    .await
    .map_err(internal_server_error)?
    .ok_or(JsonError(BannerNotFoundError { banner_id }))?;

    let banner = PackBanner {
        id: row.id,
        start_date: row.start_date,
        end_date: row.end_date,
    };

    Ok(Json(GetBannerResponse {
        banner,
        banner_cards: row.distribution.unwrap().0,
    }))
}

#[cfg(test)]
mod tests {
    use crate::api::errors::{ApiError, BannerNotFoundError, ErrorDetailResponse};
    use crate::test::prelude::*;
    use axum::http::Request;
    use axum::http::StatusCode;
    use sqlx::PgPool;
    use time::{Date, Month, OffsetDateTime, Time};

    use super::GetBannerResponse;

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed"))
    )]
    async fn get_banner_ok(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get("/api/v1/banners/base-standard")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: GetBannerResponse = response.json().await.unwrap();
        assert_eq!(response.banner.id, "base-standard");
        assert_eq!(
            response.banner.start_date,
            OffsetDateTime::new_utc(
                Date::from_calendar_date(2026, Month::January, 1).unwrap(),
                Time::MIDNIGHT,
            )
        );
        assert_eq!(response.banner.end_date, None);
        assert_eq!(response.banner_cards.len(), 14);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed"))
    )]
    async fn get_banner_done(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get("/api/v1/banners/default").empty().unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: GetBannerResponse = response.json().await.unwrap();
        assert_eq!(response.banner.id, "default");
        assert!(response.banner_cards.is_empty());
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed"))
    )]
    async fn get_banner_upcoming(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get("/api/v1/banners/upcoming-holiday")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: GetBannerResponse = response.json().await.unwrap();
        assert_eq!(response.banner.id, "upcoming-holiday");
        assert!(response.banner_cards.is_empty());
    }

    #[sqlx::test(migrator = "MIGRATOR")]
    async fn get_banner_not_found(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::get("/api/v1/banners/fake-banner").empty().unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);

        let response: ErrorDetailResponse = response.json().await.unwrap();
        assert_eq!(response.code, BannerNotFoundError::CODE);
    }
}
