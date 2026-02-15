use http_body_util::BodyExt;

pub trait ResponseExt {
    async fn json<T: serde::de::DeserializeOwned>(self) -> anyhow::Result<T>;
}

impl ResponseExt for axum::response::Response {
    async fn json<T: serde::de::DeserializeOwned>(self) -> anyhow::Result<T> {
        Ok(serde_json::from_slice(
            &self.into_body().collect().await.unwrap().to_bytes(),
        )?)
    }
}

pub mod prelude {
    pub use super::ResponseExt as _;
    pub use tower::ServiceExt as _;

    pub const MIGRATOR: sqlx::migrate::Migrator =
        cartography_macros::graphile_migrate!("migrations/committed");
}
