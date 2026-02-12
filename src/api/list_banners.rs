use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::Json;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::dto::*;

#[derive(Serialize, Deserialize, ToSchema)]
pub struct ListBannersResponse {
    banners: Vec<PackBanner>,
}

fn default_active() -> Vec<Status> {
    vec![Status::Active]
}

#[derive(Serialize, Deserialize, ToSchema)]
#[schema(default)]
pub struct ListBannersRequest {
    #[serde(default = "default_active")]
    status: Vec<Status>,
}

impl Default for ListBannersRequest {
    fn default() -> Self {
        Self {
            status: vec![Status::Active],
        }
    }
}

#[derive(Serialize, Deserialize, PartialEq, Eq, Copy, Clone, Debug, ToSchema)]
pub enum Status {
    Done,
    Active,
    Upcoming,
}

#[utoipa::path(
    post,
    path = "/api/v1/banners",
    description = "List pack banners.",
    tag = "Global",
    request_body = Option<ListBannersRequest>,
    responses(
        (status = OK, description = "Successfully listed all banners.", body = ListBannersResponse),
    ),
)]
pub async fn list_banners(
    db: axum::Extension<sqlx::PgPool>,
    request: Option<Json<ListBannersRequest>>,
) -> Result<Json<ListBannersResponse>, Response> {
    let request = request.map(|json| json.0).unwrap_or_default();
    let mut conn = db
        .acquire()
        .await
        .map_err(|err| (StatusCode::INTERNAL_SERVER_ERROR, err.to_string()).into_response())?;

    let banners = sqlx::query!(
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
            WHERE
                ($1 AND end_date <= NOW())
                OR ($2 AND start_date <= NOW() AND (end_date IS NULL OR end_date > NOW()))
                OR ($3 AND start_date > NOW())
            GROUP BY pack_banners.id, start_date, end_date
            ORDER BY start_date ASC
        "#,
        request.status.contains(&Status::Done),
        request.status.contains(&Status::Active),
        request.status.contains(&Status::Upcoming),
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(|err| (StatusCode::INTERNAL_SERVER_ERROR, err.to_string()).into_response())?
    .into_iter()
    .map(|record| PackBanner {
        id: record.id,
        start_date: record.start_date,
        end_date: record.end_date,
        distribution: record.distribution.unwrap().0,
    })
    .collect();

    Ok(Json(ListBannersResponse { banners }))
}
