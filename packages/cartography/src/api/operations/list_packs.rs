use crate::api::{errors::internal_server_error, middleware::authorization::Authorization};
use crate::dto::*;
use axum::{Extension, Json, extract::Path};

#[derive(serde::Serialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Deserialize))]
pub struct ListPacksResponse {
    packs: Vec<Pack>,
}

fn default_unopened() -> Vec<PackStatus> {
    vec![PackStatus::Unopened]
}

#[derive(serde::Deserialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Serialize))]
#[schema(default)]
pub struct ListPacksRequest {
    #[serde(default = "default_unopened")]
    status: Vec<PackStatus>,
}

impl Default for ListPacksRequest {
    fn default() -> Self {
        Self {
            status: vec![PackStatus::Unopened],
        }
    }
}

#[derive(
    PartialEq, Eq, Copy, Clone, Debug, serde::Serialize, serde::Deserialize, utoipa::ToSchema,
)]
pub enum PackStatus {
    Opened,
    Unopened,
}

#[utoipa::path(
    post,
    path = "/api/v1/players/{player_id}/packs",
    description = "List player packs.",
    tag = "Player",
    request_body = Option<ListPacksRequest>,
    security(("trust" = [])),
    responses(
        (status = OK, description = "Successfully listed all fields.", body = ListPacksResponse),
    ),
    params(
        ("player_id" = AccountIdOrMe, Path, description = "The ID of the player whose fields to list.")
    )
)]
pub async fn list_packs(
    db: axum::Extension<sqlx::PgPool>,
    Extension(authorization): Extension<Authorization>,
    Path(account_id): Path<AccountIdOrMe>,
    request: Option<Json<ListPacksRequest>>,
) -> axum::response::Result<Json<ListPacksResponse>> {
    let request = request.unwrap_or_default();
    let account_id = authorization.resolve_account_id(&account_id)?;
    authorization.require_authorization(account_id)?;

    let mut conn = db.acquire().await.map_err(internal_server_error)?;
    let packs = sqlx::query_as!(
        Pack,
        r#"
            SELECT packs.id, packs.pack_banner_id, packs.opened_at
            FROM packs
            WHERE
                account_id = $1
                AND (($2 AND opened_at IS NULL) OR ($3 AND opened_at IS NOT NULL))
        "#,
        account_id,
        request.status.contains(&PackStatus::Unopened),
        request.status.contains(&PackStatus::Opened),
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(internal_server_error)?;
    Ok(Json(ListPacksResponse { packs }))
}

#[cfg(test)]
mod tests {
    use crate::{api::operations::PackStatus, test::prelude::*};
    use axum::http::{Request, StatusCode};
    use sqlx::PgPool;

    use super::{ListPacksRequest, ListPacksResponse};

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("account"))
    )]
    pub fn list_packs_none(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/@me/packs")
            .header("Authorization", "Trust foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: ListPacksResponse = response.json().await.unwrap();
        assert!(response.packs.is_empty());
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn list_packs_by_name(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/foxfriends/packs")
            .header("Authorization", "Trust foxfriends")
            .json(ListPacksRequest {
                status: vec![PackStatus::Unopened],
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: ListPacksResponse = response.json().await.unwrap();
        assert_eq!(response.packs.len(), 2);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn list_packs_default_unopened(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/@me/packs")
            .header("Authorization", "Trust foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: ListPacksResponse = response.json().await.unwrap();
        assert_eq!(response.packs.len(), 2);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn list_packs_opened(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/@me/packs")
            .header("Authorization", "Trust foxfriends")
            .json(ListPacksRequest {
                status: vec![PackStatus::Opened],
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: ListPacksResponse = response.json().await.unwrap();
        assert_eq!(response.packs.len(), 1);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn list_packs_all(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/@me/packs")
            .header("Authorization", "Trust foxfriends")
            .json(ListPacksRequest {
                status: vec![PackStatus::Unopened, PackStatus::Opened],
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: ListPacksResponse = response.json().await.unwrap();
        assert_eq!(response.packs.len(), 3);
    }

    #[sqlx::test(migrator = "MIGRATOR")]
    pub fn list_packs_requires_authentication(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/players/foxfriends/packs")
            .json(ListPacksRequest {
                status: vec![PackStatus::Unopened, PackStatus::Opened],
            })
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
    }
}
