use super::super::Unsubscribe;
use super::PlayerSocket;
use uuid::Uuid;

impl PlayerSocket {
    pub(super) async fn unsubscribe(&mut self, message_id: Uuid) -> anyhow::Result<()> {
        if let Some(sub) = self.subscriptions.remove(&message_id) {
            sub.tell(Unsubscribe).await?;
        }
        Ok(())
    }
}
