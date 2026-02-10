use serde::{Deserialize, Serialize};

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

pub use server::PlayerSocket;

mod server {
    mod authenticate;

    use super::{Request, Response};
    use futures::Stream;
    use kameo::prelude::*;
    use sqlx::PgPool;
    use tokio::sync::mpsc::{unbounded_channel, UnboundedSender};
    use tokio_stream::wrappers::UnboundedReceiverStream;

    #[derive(Actor)]
    pub struct PlayerSocket {
        pub(super) db: PgPool,
        pub(super) account_id: Option<String>,
    }

    impl PlayerSocket {
        pub fn build(db: PgPool) -> Self {
            Self {
                db,
                account_id: None,
            }
        }

        pub async fn push(
            actor: ActorRef<Self>,
            request: Request,
        ) -> Result<impl Stream<Item = Response>, SendError<PlayerSocketMessage>> {
            let (tx, rx) = unbounded_channel();
            actor.tell(PlayerSocketMessage { tx, request }).await?;
            Ok(UnboundedReceiverStream::new(rx))
        }
    }

    pub struct PlayerSocketMessage {
        tx: UnboundedSender<Response>,
        request: Request,
    }

    impl Message<PlayerSocketMessage> for PlayerSocket {
        type Reply = ();

        async fn handle(
            &mut self,
            PlayerSocketMessage { tx, request }: PlayerSocketMessage,
            ctx: &mut Context<Self, Self::Reply>,
        ) -> Self::Reply {
            let result = match request {
                Request::Authenticate(account_id) => self.authenticate(tx, account_id).await,
            };
            if let Err(error) = result {
                tracing::error!("error handling player socket message: {}", error);
                ctx.stop()
            }
        }
    }
}
