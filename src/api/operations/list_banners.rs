use crate::api::error::internal_server_error;
use crate::dto::*;
use axum::Json;

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct ListBannersResponse {
    banners: Vec<PackBanner>,
}

fn default_active() -> Vec<Status> {
    vec![Status::Active]
}

#[derive(serde::Deserialize, utoipa::ToSchema)]
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

#[derive(
    PartialEq, Eq, Copy, Clone, Debug, serde::Serialize, serde::Deserialize, utoipa::ToSchema,
)]
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
) -> axum::response::Result<Json<ListBannersResponse>> {
    let request = request.map(|json| json.0).unwrap_or_default();
    let mut conn = db.acquire().await.map_err(internal_server_error)?;

    let banners = sqlx::query!(
        r#"
            SELECT
                pack_banners.id,
                start_date,
                end_date
            FROM pack_banners
            WHERE
                ($1 AND end_date <= NOW())
                OR ($2 AND start_date <= NOW() AND (end_date IS NULL OR end_date > NOW()))
                OR ($3 AND start_date > NOW())
            ORDER BY start_date ASC
        "#,
        request.status.contains(&Status::Done),
        request.status.contains(&Status::Active),
        request.status.contains(&Status::Upcoming),
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(internal_server_error)?
    .into_iter()
    .map(|record| PackBanner {
        id: record.id,
        start_date: record.start_date,
        end_date: record.end_date,
    })
    .collect();

    Ok(Json(ListBannersResponse { banners }))
}
