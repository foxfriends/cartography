use crate::dto::{Account, Field};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type", content = "data")]
pub enum Request {
    Authenticate(String),
    ListFields,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type", content = "data")]
pub enum Response {
    Authenticated(Account),
    FieldList(Vec<Field>),
}

pub use server::PlayerSocket;

mod server {
    use super::{Request, Response};
    use futures::Stream;
    use kameo::prelude::*;
    use sqlx::PgPool;
    use tokio::sync::mpsc::{unbounded_channel, UnboundedSender};
    use tokio_stream::wrappers::UnboundedReceiverStream;

    mod authenticate;
    mod list_fields;

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
                Request::ListFields if self.account_id.is_some() => {
                    self.list_fields(tx).await
                }
                _ => Err(anyhow::anyhow!("authentication required"))
            };
            if let Err(error) = result {
                tracing::error!("error handling player socket message: {}", error);
                ctx.stop()
            }
        }
    }
}
