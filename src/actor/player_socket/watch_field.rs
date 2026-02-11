use super::super::field_state::FieldWatcher;
use super::super::Unsubscribe;
use super::{PlayerSocket, Response};
use kameo::actor::Spawn;
use tokio::sync::mpsc::UnboundedSender;
use uuid::Uuid;

impl PlayerSocket {
    pub(super) async fn watch_field(
        &mut self,
        tx: UnboundedSender<Response>,
        message_id: Uuid,
        field_id: i64,
    ) -> anyhow::Result<()> {
        let actor = FieldWatcher::spawn(FieldWatcher::build(self.db.clone(), tx, field_id).await?);
        let unsubscriber = actor.recipient::<Unsubscribe>();
        self.subscriptions.insert(message_id, unsubscriber);
        Ok(())
    }
}
