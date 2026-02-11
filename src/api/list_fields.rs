use axum::extract::Path;
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::Json;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::dto::*;

#[derive(Serialize, Deserialize, ToSchema)]
pub struct ListFieldsResponse {
    fields: Vec<Field>,
}

#[derive(Serialize, Deserialize, ToSchema)]
#[serde(untagged)]
pub enum AccountIdOrMe {
    #[serde(rename = "@me")]
    Me,
    AccountId(String),
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
) -> Result<Json<ListFieldsResponse>, Response> {
    let AccountIdOrMe::AccountId(account_id) = player_id else {
        return Err((
            StatusCode::INTERNAL_SERVER_ERROR,
            "unimplemented".to_owned(),
        )
            .into_response());
    };
    let mut conn = db
        .acquire()
        .await
        .map_err(|err| (StatusCode::INTERNAL_SERVER_ERROR, err.to_string()).into_response())?;
    let fields = sqlx::query_as!(
        Field,
        "SELECT id, name FROM fields WHERE account_id = $1",
        account_id,
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(|err| (StatusCode::INTERNAL_SERVER_ERROR, err.to_string()).into_response())?;
    Ok(Json(ListFieldsResponse { fields }))
}
