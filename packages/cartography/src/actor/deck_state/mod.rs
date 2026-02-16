use super::player_socket::Response;
use super::{AddCardToDeck, Unsubscribe};
use crate::bus::{Bus, BusExt};
use crate::db::CardClass;
use kameo::prelude::*;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use tokio::sync::mpsc::UnboundedSender;

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize)]
pub struct Tile {
    pub id: i64,
    pub tile_type_id: String,
    pub name: String,
}

#[derive(PartialEq, Clone, Debug, Serialize, Deserialize)]
pub struct Citizen {
    pub id: i64,
    pub species_id: String,
    pub name: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct DeckState {
    pub tiles: Vec<Tile>,
    pub citizens: Vec<Citizen>,
}

pub struct DeckWatcher {
    state: DeckState,
    account_id: String,
    db: PgPool,
    tx: UnboundedSender<Response>,
}

impl Actor for DeckWatcher {
    type Args = (PgPool, UnboundedSender<Response>, ActorRef<Bus>, String);
    type Error = anyhow::Error;

    async fn on_start(
        (db, tx, bus, account_id): Self::Args,
        actor_ref: ActorRef<Self>,
    ) -> Result<Self, Self::Error> {
        let mut conn = db.acquire().await?;

        bus.listen::<AddCardToDeck, _>(&actor_ref).await?;

        let tiles = sqlx::query_as!(
            Tile,
            r#"
                SELECT id, tile_type_id, name
                FROM tiles
                INNER JOIN card_accounts ON card_accounts.card_id = tiles.id
                WHERE card_accounts.account_id = $1
            "#,
            account_id
        )
        .fetch_all(&mut *conn)
        .await?;
        let citizens = sqlx::query_as!(
            Citizen,
            r#"
                SELECT id, species_id, name
                FROM citizens
                INNER JOIN card_accounts ON card_accounts.card_id = citizens.id
                WHERE card_accounts.account_id = $1
            "#,
            account_id
        )
        .fetch_all(&mut *conn)
        .await?;
        let state = DeckState { tiles, citizens };

        tx.send(Response::PutDeckState(state.clone()))?;

        Ok(Self {
            state,
            db,
            tx,
            account_id,
        })
    }
}

impl DeckWatcher {
    async fn send_patch(&self, previous: &serde_json::Value) -> anyhow::Result<()> {
        let next = serde_json::to_value(&self.state).unwrap();
        let patch = json_patch::diff(previous, &next);
        self.tx.send(Response::PatchState(patch))?;
        Ok(())
    }

    async fn add_card(&mut self, card_id: i64) -> anyhow::Result<()> {
        let mut conn = self.db.acquire().await?;
        let card = sqlx::query!(
            r#"
                SELECT cards.card_type_id, card_types.class AS "class: CardClass"
                FROM cards
                INNER JOIN card_types ON card_types.id = cards.card_type_id
                INNER JOIN card_accounts ON card_accounts.card_id = cards.id
                WHERE cards.id = $1 AND card_accounts.account_id = $2
            "#,
            card_id,
            self.account_id
        )
        .fetch_one(&mut *conn)
        .await?;

        let previous = serde_json::to_value(&self.state).unwrap();
        match card.class {
            CardClass::Tile => {
                let tile = sqlx::query_as!(
                    Tile,
                    "SELECT id, tile_type_id, name FROM tiles WHERE id = $1",
                    card_id
                )
                .fetch_one(&mut *conn)
                .await?;
                self.state.tiles.retain(|tile| tile.id != card_id);
                self.state.tiles.push(tile);
            }
            CardClass::Citizen => {
                let citizen = sqlx::query_as!(
                    Citizen,
                    "SELECT id, species_id, name FROM citizens WHERE id = $1",
                    card_id
                )
                .fetch_one(&mut *conn)
                .await?;
                self.state.citizens.retain(|citizen| citizen.id != card_id);
                self.state.citizens.push(citizen);
            }
        }
        self.send_patch(&previous).await?;
        Ok(())
    }
}

impl Message<AddCardToDeck> for DeckWatcher {
    type Reply = ();

    async fn handle(
        &mut self,
        msg: AddCardToDeck,
        _ctx: &mut Context<Self, Self::Reply>,
    ) -> Self::Reply {
        #[expect(
            clippy::collapsible_if,
            reason = "confusing use of side effects when collapsed"
        )]
        if msg.account_id == self.account_id {
            if let Err(error) = self.add_card(msg.card_id).await {
                tracing::error!("{}", error);
                panic!("aborting deck watcher: {}", error);
            }
        }
    }
}

impl Message<Unsubscribe> for DeckWatcher {
    type Reply = ();
    async fn handle(
        &mut self,
        _msg: Unsubscribe,
        ctx: &mut kameo::prelude::Context<Self, Self::Reply>,
    ) -> Self::Reply {
        ctx.stop();
    }
}
