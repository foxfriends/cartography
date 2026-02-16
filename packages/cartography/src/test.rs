use std::any::Any;

use axum::{body::Body, http::Request};
use http_body_util::BodyExt;
use kameo::prelude::*;

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

#[derive(Actor)]
pub struct Collector<T: Any + Clone + Sync + Send>(Vec<T>);

impl<T: Any + Clone + Sync + Send> Default for Collector<T> {
    fn default() -> Self {
        Self(vec![])
    }
}

struct TakeCollection;

impl<T: Any + Clone + Sync + Send> Message<T> for Collector<T> {
    type Reply = ();

    async fn handle(
        &mut self,
        msg: T,
        _ctx: &mut kameo::prelude::Context<Self, Self::Reply>,
    ) -> Self::Reply {
        self.0.push(msg);
    }
}

impl<T: Any + Clone + Sync + Send> Message<TakeCollection> for Collector<T> {
    type Reply = Vec<T>;

    async fn handle(
        &mut self,
        _msg: TakeCollection,
        ctx: &mut kameo::prelude::Context<Self, Self::Reply>,
    ) -> Self::Reply {
        ctx.stop();
        std::mem::take(&mut self.0)
    }
}

pub trait CollectorExt<T> {
    async fn collect(self) -> Vec<T>;
}

impl<T: Any + Clone + Sync + Send> CollectorExt<T> for ActorRef<Collector<T>> {
    async fn collect(self) -> Vec<T> {
        self.ask(TakeCollection).await.unwrap()
    }
}

pub mod prelude {
    pub use super::Collector;
    pub use super::CollectorExt as _;
    pub use super::{RequestExt as _, ResponseExt as _};
    pub use tower::ServiceExt as _;

    pub const MIGRATOR: sqlx::migrate::Migrator =
        cartography_macros::graphile_migrate!("migrations/committed");
    pub(crate) use super::assert_success;
}
