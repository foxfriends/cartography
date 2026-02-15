use crate::api::errors::{
    BannerNotFoundError, ErrorDetailResponse, JsonError, internal_server_error,
};
use crate::dto::*;
use axum::Json;
use axum::extract::Path;

#[derive(serde::Serialize, utoipa::ToSchema)]
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
