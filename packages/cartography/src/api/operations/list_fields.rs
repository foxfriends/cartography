use crate::api::errors::internal_server_error;
use crate::api::middleware::authorization::Authorization;
use crate::dto::*;
use axum::extract::Path;
use axum::{Extension, Json};

#[derive(serde::Serialize, utoipa::ToSchema)]
pub struct ListFieldsResponse {
    fields: Vec<Field>,
}

#[utoipa::path(
    get,
    path = "/api/v1/players/{player_id}/fields",
    description = "List player fields.",
    tag = "Player",
    responses(
        (status = OK, description = "Successfully listed all fields.", body = ListFieldsResponse),
    ),
    params(
        ("player_id" = AccountIdOrMe, Path, description = "The ID of the player whose fields to list.")
    )
)]
pub async fn list_fields(
    db: axum::Extension<sqlx::PgPool>,
    Extension(authorization): Extension<Authorization>,
    Path(account_id): Path<AccountIdOrMe>,
) -> axum::response::Result<Json<ListFieldsResponse>> {
    let account_id = authorization.resolve_account_id(&account_id)?;
    authorization.require_authorization(account_id)?;

    let mut conn = db.acquire().await.map_err(internal_server_error)?;
    let fields = sqlx::query_as!(
        Field,
        "SELECT id, name FROM fields WHERE account_id = $1",
        account_id,
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(internal_server_error)?;
    Ok(Json(ListFieldsResponse { fields }))
}
