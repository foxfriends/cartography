use http_body_util::BodyExt;

pub trait ResponseExt {
    async fn json<T: serde::de::DeserializeOwned>(self) -> anyhow::Result<T>;
    async fn text(self) -> anyhow::Result<String>;
}

impl ResponseExt for axum::response::Response {
    async fn json<T: serde::de::DeserializeOwned>(self) -> anyhow::Result<T> {
        Ok(serde_json::from_slice(
            &self.into_body().collect().await?.to_bytes(),
        )?)
    }

    async fn text(self) -> anyhow::Result<String> {
        Ok(String::from_utf8(
            self.into_body().collect().await?.to_bytes().to_vec(),
        )?)
    }
}

macro_rules! assert_success {
    ($response:expr) => {
        assert!(
            $response.status().is_success(),
            "{}",
            $response
                .text()
                .await
                .expect("response body was not valid utf-8")
        )
    };
}

pub(crate) use assert_success;

pub mod prelude {
    pub use super::ResponseExt as _;
    pub use tower::ServiceExt as _;

    pub const MIGRATOR: sqlx::migrate::Migrator =
        cartography_macros::graphile_migrate!("migrations/committed");
    pub(crate) use super::assert_success;
}
