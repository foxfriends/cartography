use super::{PlayerSocket, Response};
use tokio::sync::mpsc::UnboundedSender;

impl PlayerSocket {
    pub(super) async fn authenticate(
        &mut self,
        tx: UnboundedSender<Response>,
        account_id: String,
    ) -> anyhow::Result<()> {
        struct Account {
            id: String,
        }
        let mut conn = self.db.begin().await?;
        let account = sqlx::query_as!(Account, "SELECT id FROM accounts WHERE id = $1", account_id)
            .fetch_optional(&mut *conn)
            .await?;
        let account = match account {
            Some(account) => account,
            None => {
                sqlx::query_as!(
                    Account,
                    "INSERT INTO accounts (id) VALUES ($1) RETURNING id",
                    account_id
                )
                .fetch_one(&mut *conn)
                .await?
            }
        };
        conn.commit().await?;
        self.account_id = Some(account.id.clone());
        tx.send(Response::Authenticated(account.id))?;
        Ok(())
    }
}
