use axum::Json;
use axum::extract::Path;

use crate::api::errors::{internal_server_error, respond_internal_server_error};
use crate::dto::*;

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
    Path(player_id): Path<AccountIdOrMe>,
) -> axum::response::Result<Json<ListFieldsResponse>> {
    dbg!(&player_id);
    let AccountIdOrMe::AccountId(account_id) = player_id else {
        respond_internal_server_error!("unimplemented");
    };
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
