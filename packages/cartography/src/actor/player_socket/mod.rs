use super::field_state::FieldState;
use crate::actor::{Unsubscribe, deck_state::DeckState};
use crate::api::ws::ProtocolV1Message;
use crate::bus::Bus;
use crate::dto::Account;
use futures::Stream;
use json_patch::Patch;
use kameo::prelude::*;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use std::collections::HashMap;
use tokio::sync::mpsc::{UnboundedSender, unbounded_channel};
use tokio_stream::wrappers::UnboundedReceiverStream;
use uuid::Uuid;

mod authenticate;
mod unsubscribe;
mod watch_deck;
mod watch_field;

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type", content = "data")]
pub enum Request {
    Authenticate(String),
    WatchDeck,
    WatchField(i64),
    Unsubscribe,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type", content = "data")]
pub enum Response {
    Authenticated(Account),
    PutFieldState(FieldState),
    PutDeckState(DeckState),
    PatchState(Patch),
}

#[derive(Actor)]
pub struct PlayerSocket {
    db: PgPool,
    bus: ActorRef<Bus>,
    account_id: Option<String>,
    subscriptions: HashMap<Uuid, Recipient<Unsubscribe>>,
}

impl PlayerSocket {
    pub fn build(db: PgPool, bus: ActorRef<Bus>) -> Self {
        Self {
            db,
            bus,
            account_id: None,
            subscriptions: HashMap::default(),
        }
    }

    pub async fn push(
        actor: ActorRef<Self>,
        request: ProtocolV1Message<Request>,
    ) -> Result<impl Stream<Item = Response>, SendError<PlayerSocketMessage>> {
        let (tx, rx) = unbounded_channel();
        actor.tell(PlayerSocketMessage { tx, request }).await?;
        Ok(UnboundedReceiverStream::new(rx))
    }

    fn require_authentication(&self) -> anyhow::Result<&str> {
        self.account_id
            .as_deref()
            .ok_or_else(|| anyhow::anyhow!("authentication required"))
    }
}

pub struct PlayerSocketMessage {
    tx: UnboundedSender<Response>,
    request: ProtocolV1Message<Request>,
}

impl Message<PlayerSocketMessage> for PlayerSocket {
    type Reply = ();

    async fn handle(
        &mut self,
        PlayerSocketMessage { tx, request }: PlayerSocketMessage,
        ctx: &mut Context<Self, Self::Reply>,
    ) -> Self::Reply {
        let result = match request.data {
            Request::Authenticate(account_id) => self.authenticate(tx, account_id).await,
            Request::WatchField(field_id) => self.watch_field(tx, request.id, field_id).await,
            Request::WatchDeck => self.watch_deck(tx, request.id).await,
            Request::Unsubscribe => self.unsubscribe(request.id).await,
        };
        if let Err(error) = result {
            tracing::error!("error handling player socket message: {}", error);
            ctx.stop()
        }
    }
}
