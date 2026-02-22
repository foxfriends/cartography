use crate::actor::AddCardToDeck;
use crate::api::errors::{ErrorDetailResponse, JsonError, PackNotFoundError};
use crate::api::{errors::internal_server_error, middleware::authorization::Authorization};
use crate::bus::{Bus, BusExt};
use crate::dto::*;
use axum::{Extension, Json, extract::Path};
use kameo::actor::ActorRef;

#[derive(serde::Serialize, utoipa::ToSchema)]
#[cfg_attr(test, derive(serde::Deserialize))]
pub struct OpenPackResponse {
    pack: Pack,
    pack_cards: Vec<Card>,
}

#[utoipa::path(
    post,
    path = "/api/v1/packs/{pack_id}/open",
    description = "Open a pack. This request is idempotent: opening a pack a second time does nothing, but returns the pack.",
    tags = ["Game", "Pack", "Player"],
    security(("trust" = [])),
    responses(
        (status = OK, description = "Successfully opened pack.", body = OpenPackResponse),
        (status = NOT_FOUND, description = "Pack not found, or not your pack.", body = ErrorDetailResponse),
    ),
    params(
        ("pack_id" = i64, Path, description = "The ID of the pack to open.")
    )
)]
pub async fn open_pack(
    db: Extension<sqlx::PgPool>,
    authorization: Extension<Authorization>,
    bus: Extension<ActorRef<Bus>>,
    Path(pack_id): Path<i64>,
) -> axum::response::Result<Json<OpenPackResponse>> {
    let account_id = authorization.authorized_account_id()?;
    let mut conn = db.begin().await.map_err(internal_server_error)?;

    let mut pack = sqlx::query_as!(
        Pack,
        r#"
            SELECT packs.id, packs.pack_banner_id, packs.opened_at
            FROM packs
            WHERE id = $1 AND account_id = $2
        "#,
        pack_id,
        account_id,
    )
    .fetch_optional(&mut *conn)
    .await
    .map_err(internal_server_error)?
    .ok_or(JsonError(PackNotFoundError { pack_id }))?;

    let pack_cards = sqlx::query_as!(
        Card,
        r#"
            SELECT id, card_type_id
            FROM cards
            INNER JOIN pack_contents ON pack_contents.card_id = cards.id
            WHERE pack_contents.pack_id = $1
        "#,
        pack_id,
    )
    .fetch_all(&mut *conn)
    .await
    .map_err(internal_server_error)?;

    let mut just_opened = true;
    if pack.opened_at.is_none() {
        let update = sqlx::query!(
            "UPDATE packs SET opened_at = now() WHERE id = $1 RETURNING opened_at",
            pack_id
        )
        .fetch_one(&mut *conn)
        .await
        .map_err(internal_server_error)?;
        pack.opened_at = update.opened_at;
    } else {
        just_opened = false;
    }

    conn.commit().await.map_err(internal_server_error)?;

    if just_opened {
        for card in &pack_cards {
            bus.notify(AddCardToDeck {
                account_id: account_id.to_owned(),
                card_id: card.id,
            })
            .await
            .ok();
        }
    }

    Ok(Json(OpenPackResponse { pack, pack_cards }))
}

#[cfg(test)]
mod tests {
    use crate::actor::AddCardToDeck;
    use crate::bus::{Bus, BusExt};
    use crate::test::prelude::*;
    use axum::http::{Request, StatusCode};
    use kameo::actor::Spawn;
    use sqlx::PgPool;

    use super::OpenPackResponse;

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn open_pack_ok(pool: PgPool) {
        let pack = sqlx::query!(
            "SELECT id FROM packs WHERE account_id = 'foxfriends' AND opened_at IS NULL"
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        let collector = Collector::<AddCardToDeck>::spawn_default();
        let bus = Bus::spawn(());
        bus.listen::<AddCardToDeck, _>(&collector).await.unwrap();

        let app = crate::app::Config::test(pool).with_bus(bus).into_router();

        let request = Request::post(format!("/api/v1/packs/{}/open", pack.id))
            .header("Authorization", "Trust foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: OpenPackResponse = response.json().await.unwrap();
        assert!(response.pack.opened_at.is_some());
        assert_eq!(response.pack_cards.len(), 5);

        let received = collector.collect().await;
        assert!(
            response
                .pack_cards
                .iter()
                .all(|item| received.iter().any(|msg| msg.card_id == item.id)),
            "all opened cards should have been broadcast"
        );
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn open_pack_already_opened_ok(pool: PgPool) {
        let pack = sqlx::query!(
            "SELECT id, opened_at FROM packs WHERE account_id = 'foxfriends' AND opened_at IS NOT NULL"
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        let collector = Collector::<AddCardToDeck>::spawn_default();
        let bus = Bus::spawn_default();
        bus.listen::<AddCardToDeck, _>(&collector).await.unwrap();

        let app = crate::app::Config::test(pool).with_bus(bus).into_router();

        let request = Request::post(format!("/api/v1/packs/{}/open", pack.id))
            .header("Authorization", "Trust foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_success!(response);

        let response: OpenPackResponse = response.json().await.unwrap();
        assert_eq!(response.pack.opened_at, pack.opened_at);
        assert_eq!(response.pack_cards.len(), 5);

        let received = collector.collect().await;
        assert!(
            received.is_empty(),
            "previously opened cards do not get re-broadcast"
        );
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("account"))
    )]
    pub fn open_pack_not_found(pool: PgPool) {
        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post("/api/v1/packs/1/open")
            .header("Authorization", "Trust foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account", "packs"))
    )]
    pub fn open_pack_not_owned(pool: PgPool) {
        let pack = sqlx::query!(
            "SELECT id FROM packs WHERE account_id = 'foxfriends' AND opened_at IS NULL"
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        let app = crate::app::Config::test(pool).into_router();

        let request = Request::post(format!("/api/v1/packs/{}/open", pack.id))
            .header("Authorization", "Trust not-foxfriends")
            .empty()
            .unwrap();

        let Ok(response) = app.oneshot(request).await;
        assert_eq!(response.status(), StatusCode::NOT_FOUND);
    }
}
