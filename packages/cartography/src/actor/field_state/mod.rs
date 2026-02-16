use super::Unsubscribe;
use super::player_socket::Response;
use kameo::prelude::*;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use tokio::sync::mpsc::UnboundedSender;

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct FieldTile {
    pub id: i64,
    pub x: i32,
    pub y: i32,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct FieldCitizen {
    pub id: i64,
    pub x: i32,
    pub y: i32,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct FieldState {
    pub name: String,
    pub tiles: Vec<FieldTile>,
    pub citizens: Vec<FieldCitizen>,
}

#[derive(Actor)]
#[expect(dead_code)]
pub struct FieldWatcher {
    state: FieldState,
    field_id: i64,
    db: PgPool,
    tx: UnboundedSender<Response>,
}

impl FieldWatcher {
    pub async fn build(
        db: PgPool,
        tx: UnboundedSender<Response>,
        field_id: i64,
        account_id: &str,
    ) -> anyhow::Result<Self> {
        let mut conn = db.acquire().await?;

        let field = sqlx::query!(
            "SELECT name FROM fields WHERE id = $1 AND account_id = $2",
            field_id,
            account_id
        )
        .fetch_one(&mut *conn)
        .await?;
        let tiles = sqlx::query_as!(
            FieldTile,
            r#"
                SELECT tile_id AS "id", grid_x AS "x", grid_y AS "y"
                FROM field_tiles
                WHERE field_id = $1
            "#,
            field_id
        )
        .fetch_all(&mut *conn)
        .await?;
        let citizens = sqlx::query_as!(
            FieldCitizen,
            r#"
                SELECT citizen_id AS "id", grid_x AS "x", grid_y AS "y"
                FROM field_citizens
                WHERE field_id = $1
            "#,
            field_id
        )
        .fetch_all(&mut *conn)
        .await?;
        let state = FieldState {
            name: field.name,
            tiles,
            citizens,
        };
        tx.send(Response::PutFieldState(state.clone()))?;
        Ok(Self {
            state,
            db,
            tx,
            field_id,
        })
    }
}

impl Message<Unsubscribe> for FieldWatcher {
    type Reply = ();
    async fn handle(
        &mut self,
        _msg: Unsubscribe,
        ctx: &mut kameo::prelude::Context<Self, Self::Reply>,
    ) -> Self::Reply {
        ctx.stop();
    }
}
