use super::super::Unsubscribe;
use super::super::deck_state::DeckWatcher;
use super::{PlayerSocket, Response};
use kameo::actor::Spawn;
use tokio::sync::mpsc::UnboundedSender;
use uuid::Uuid;

impl PlayerSocket {
    pub(super) async fn watch_deck(
        &mut self,
        tx: UnboundedSender<Response>,
        message_id: Uuid,
    ) -> anyhow::Result<()> {
        let account_id = self.require_authentication()?;
        let actor =
            DeckWatcher::spawn((self.db.clone(), tx, self.bus.clone(), account_id.to_owned()));
        let unsubscriber = actor.recipient::<Unsubscribe>();
        self.subscriptions.insert(message_id, unsubscriber);
        Ok(())
    }
}
