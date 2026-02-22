use super::player_socket::Response;
use super::{AddCardToDeck, Unsubscribe};
use crate::bus::{Bus, BusExt};
use crate::db::CardClass;
use kameo::prelude::*;
use sqlx::PgPool;
use tokio::sync::mpsc::UnboundedSender;

#[derive(PartialEq, Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct Tile {
    pub id: i64,
    pub tile_type_id: String,
    pub name: String,
}

#[derive(PartialEq, Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct Citizen {
    pub id: i64,
    pub species_id: String,
    pub name: String,
}

#[derive(PartialEq, Clone, Default, Debug, kameo::Reply, serde::Serialize, serde::Deserialize)]
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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::actor::AddCardToDeck;
    use crate::actor::player_socket::Response;
    use crate::bus::{Bus, BusExt};
    use crate::test::prelude::*;
    use kameo::actor::Spawn;
    use sqlx::PgPool;
    use tokio::sync::mpsc::unbounded_channel;

    struct GetState;
    impl Message<GetState> for DeckWatcher {
        type Reply = DeckState;

        async fn handle(
            &mut self,
            _msg: GetState,
            _ctx: &mut Context<Self, Self::Reply>,
        ) -> Self::Reply {
            self.state.clone()
        }
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account"))
    )]
    async fn add_card_to_deck_tile(pool: PgPool) {
        let (tx, mut rx) = unbounded_channel();
        let bus = Bus::spawn_default();
        let deck_watcher =
            DeckWatcher::spawn((pool.clone(), tx, bus.clone(), "foxfriends".to_owned()));

        matches!(rx.recv().await.unwrap(), Response::PutDeckState(..));

        let card = sqlx::query_as!(
            Tile,
            r#"
                WITH inserted_card AS (
                    INSERT INTO cards (card_type_id) VALUES ('bread-bakery') RETURNING *
                ),

                inserted_card_account AS (
                    INSERT INTO card_accounts (card_id, account_id)
                    SELECT id, 'foxfriends'
                    FROM inserted_card
                )

                INSERT INTO tiles (id, tile_type_id, name)
                SELECT id, card_type_id, card_type_id
                FROM inserted_card
                RETURNING id, tile_type_id, name
            "#
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        bus.notify(AddCardToDeck {
            account_id: "foxfriends".to_owned(),
            card_id: card.id,
        })
        .await
        .unwrap();

        matches!(rx.recv().await.unwrap(), Response::PatchState(..));

        assert_eq!(
            deck_watcher.ask(GetState).await.unwrap(),
            DeckState {
                tiles: vec![card],
                citizens: vec![],
            }
        )
    }

    #[sqlx::test(
        migrator = "MIGRATOR",
        fixtures(path = "../../../fixtures", scripts("seed", "account"))
    )]
    async fn add_card_to_deck_citizen(pool: PgPool) {
        let (tx, mut rx) = unbounded_channel();
        let bus = Bus::spawn_default();
        let deck_watcher =
            DeckWatcher::spawn((pool.clone(), tx, bus.clone(), "foxfriends".to_owned()));

        matches!(rx.recv().await.unwrap(), Response::PutDeckState(..));

        let card = sqlx::query_as!(
            Citizen,
            r#"
                WITH inserted_card AS (
                    INSERT INTO cards (card_type_id) VALUES ('rabbit') RETURNING *
                ),

                inserted_card_account AS (
                    INSERT INTO card_accounts (card_id, account_id)
                    SELECT id, 'foxfriends'
                    FROM inserted_card
                )

                INSERT INTO citizens (id, species_id, name)
                SELECT id, card_type_id, card_type_id
                FROM inserted_card
                RETURNING id, species_id, name
            "#
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        bus.notify(AddCardToDeck {
            account_id: "foxfriends".to_owned(),
            card_id: card.id,
        })
        .await
        .unwrap();

        matches!(rx.recv().await.unwrap(), Response::PatchState(..));

        assert_eq!(
            deck_watcher.ask(GetState).await.unwrap(),
            DeckState {
                tiles: vec![],
                citizens: vec![card],
            }
        )
    }
}
