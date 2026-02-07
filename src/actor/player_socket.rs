use futures::Stream;
use serde::{Deserialize, Serialize};
use tokio::sync::mpsc::{unbounded_channel, UnboundedSender};
use tokio_stream::wrappers::UnboundedReceiverStream;

#[cfg(feature = "server")]
use kameo::prelude::*;

#[cfg(feature = "server")]
#[derive(Actor, Default)]
pub struct PlayerSocket {
    account_id: Option<String>,
}

#[cfg(feature = "server")]
impl PlayerSocket {
    pub async fn push(
        actor: ActorRef<Self>,
        request: Request,
    ) -> Result<impl Stream<Item = Response>, SendError<PlayerSocketMessage>> {
        let (tx, rx) = unbounded_channel();
        actor.tell(PlayerSocketMessage { tx, request }).await?;
        Ok(UnboundedReceiverStream::new(rx))
    }
}

#[cfg(feature = "server")]
pub struct PlayerSocketMessage {
    tx: UnboundedSender<Response>,
    request: Request,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type", content = "data")]
pub enum Request {
    Authenticate(String),
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type", content = "data")]
pub enum Response {
    Authenticated(String),
}

#[cfg(feature = "server")]
impl Message<PlayerSocketMessage> for PlayerSocket {
    type Reply = ();

    async fn handle(
        &mut self,
        PlayerSocketMessage { tx, request }: PlayerSocketMessage,
        _ctx: &mut Context<Self, Self::Reply>,
    ) -> Self::Reply {
        match request {
            Request::Authenticate(name) => {
                self.account_id = Some(name.clone());
                let _ = tx.send(Response::Authenticated(name));
            }
        }
    }
}
