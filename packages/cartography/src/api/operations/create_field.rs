use crate::api::errors::internal_server_error;
use crate::api::middleware::authorization::Authorization;
use crate::dto::*;
use axum::extract::Path;
use axum::{Extension, Json};

#[derive(serde::Serialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Deserialize))]
pub struct CreateFieldResponse {
    field: Field,
}

#[derive(serde::Deserialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Serialize))]
pub struct CreateFieldRequest {
    name: String,
}

#[utoipa::path(
    post,
    path = "/api/v1/players/{player_id}/fields",
    description = "Create field.",
    tag = "Player",
    security(("trust" = [])),
    request_body = CreateFieldRequest,
    responses(
        (status = OK, description = "Field created", body = CreateFieldResponse),
    ),
    params(
        ("player_id" = AccountIdOrMe, Path, description = "The ID of the player to create this field for.")
    )
)]
pub async fn create_field(
    db: Extension<sqlx::PgPool>,
    authorization: Extension<Authorization>,
    Path(account_id): Path<AccountIdOrMe>,
    request: Json<CreateFieldRequest>,
) -> axum::response::Result<Json<CreateFieldResponse>> {
    let account_id = authorization.resolve_account_id(&account_id)?;
    authorization.require_authorization(account_id)?;

    let mut conn = db.begin().await.map_err(internal_server_error)?;
    let field = sqlx::query_as!(
        Field,
        "INSERT INTO fields (name, account_id) VALUES ($1, $2) RETURNING id, name",
        request.name,
        account_id,
    )
    .fetch_one(&mut *conn)
    .await
    .map_err(internal_server_error)?;

    Ok(Json(CreateFieldResponse { field }))
}

#[cfg(test)]
mod tests {
    use crate::test::prelude::*;
    use axum::http::{Request, StatusCode};
    use sqlx::PgPool;

    use super::*;

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("account"))
    )]
    pub fn create_field(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/@me/fields")
            .header("Authorization", "Trust foxfriends")
            .json(CreateFieldRequest {
                name: "New Field".to_owned(),
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: CreateFieldResponse = response.json().await.unwrap();
        assert_eq!(response.field.name, "New Field");
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("account"))
    )]
    pub fn create_multiple_fields(pool: PgPool) {
        sqlx::query!("INSERT INTO fields (account_id, name) VALUES ('foxfriends', 'Field 1')")
            .execute(&pool)
            .await
            .unwrap();
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/@me/fields")
            .header("Authorization", "Trust foxfriends")
            .json(CreateFieldRequest {
                name: "Field 2".to_owned(),
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: CreateFieldResponse = response.json().await.unwrap();
        assert_eq!(response.field.name, "Field 2");
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("account"))
    )]
    pub fn create_field_same_name(pool: PgPool) {
        let field = sqlx::query!(
            "INSERT INTO fields (account_id, name) VALUES ('foxfriends', 'Field 1') RETURNING id"
        )
        .fetch_one(&pool)
        .await
        .unwrap();
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/@me/fields")
            .header("Authorization", "Trust foxfriends")
            .json(CreateFieldRequest {
                name: "Field 1".to_owned(),
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: CreateFieldResponse = response.json().await.unwrap();
        assert_ne!(response.field.id, field.id);
        assert_eq!(response.field.name, "Field 1");
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("account"))
    )]
    pub fn create_field_body_required(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/foxfriends/fields")
            .header("Authorization", "Trust not-foxfriends")
            .json(serde_json::json!({}))
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::UNPROCESSABLE_ENTITY);
    }

    #[sqlx::test(migrator = "MIGRATOR")]
    pub fn create_field_unauthorized(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/@me/fields")
            .json(CreateFieldRequest {
                name: "Field".to_owned(),
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("account"))
    )]
    pub fn create_field_wrong_user_forbidden(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/foxfriends/fields")
            .header("Authorization", "Trust not-foxfriends")
            .json(CreateFieldRequest {
                name: "Field".to_owned(),
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::FORBIDDEN);
    }
}
