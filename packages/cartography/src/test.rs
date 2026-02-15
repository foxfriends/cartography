use axum::{body::Body, http::Request};
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

pub trait RequestExt {
    fn empty(self) -> axum::http::Result<Request<Body>>;
    fn json<T: serde::Serialize>(self, body: T) -> axum::http::Result<Request<Body>>;
}

impl RequestExt for axum::http::request::Builder {
    fn empty(self) -> axum::http::Result<Request<Body>> {
        self.body(Body::empty())
    }

    fn json<T: serde::Serialize>(self, body: T) -> axum::http::Result<Request<Body>> {
        let body = serde_json::to_string(&body).unwrap();
        self.header("Content-Type", "application/json")
            .body(Body::from(body))
    }
}

macro_rules! assert_success {
    ($response:expr) => {
        assert!(
            $response.status().is_success(),
            "{}: {}",
            $response.status(),
            $response
                .text()
                .await
                .expect("response body was not valid utf-8")
        )
    };
}

pub(crate) use assert_success;

pub mod prelude {
    pub use super::{RequestExt as _, ResponseExt as _};
    pub use tower::ServiceExt as _;

    pub const MIGRATOR: sqlx::migrate::Migrator =
        cartography_macros::graphile_migrate!("migrations/committed");
    pub(crate) use super::assert_success;
}
