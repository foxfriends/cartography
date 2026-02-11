use super::{PlayerSocket, Response};
use crate::dto::Field;
use tokio::sync::mpsc::UnboundedSender;

impl PlayerSocket {
    pub(super) async fn list_fields(
        &mut self,
        tx: UnboundedSender<Response>,
    ) -> anyhow::Result<()> {
        let mut conn = self.db.begin().await?;
        let field_list = sqlx::query_as!(
            Field,
            "SELECT id, name FROM fields WHERE account_id = $1",
            self.require_authentication()?,
        )
        .fetch_all(&mut *conn)
        .await?;
        conn.commit().await?;
        tx.send(Response::FieldList(field_list))?;
        Ok(())
    }
}
