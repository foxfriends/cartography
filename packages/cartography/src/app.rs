use crate::api::{middleware, operations, ws};
use crate::bus::Bus;
use axum::Router;
use kameo::actor::{ActorRef, Spawn as _};
use utoipa::Modify;
use utoipa::openapi::security::{ApiKey, ApiKeyValue, SecurityScheme};

#[derive(utoipa::OpenApi)]
#[openapi(
    paths(
        operations::get_banner,
        operations::list_banners,
        operations::pull_banner,

        operations::list_card_types,

        operations::list_fields,

        operations::list_packs,
        operations::open_pack,
    ),
    components(
        schemas(
            crate::dto::AccountIdOrMe
        )
    ),
    tags(
        (name = "Global", description = "Publicly available global data about the Cartography game."),
        (name = "Player", description = "Player specific data; typically requires authorization."),
        (name = "Game", description = "Actions with effects on gameplay."),
    ),
    modifiers(&SecurityAddon)
)]
pub struct ApiDoc;

struct SecurityAddon;

impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        openapi.components.as_mut().unwrap()
                .add_security_scheme(
                    "trust",
                    SecurityScheme::ApiKey(ApiKey::Header(ApiKeyValue::with_description("Authorization", r#"DEVELOPMENT ONLY custom "auth" scheme where a header of the format `Trust {account_id}` is accepted as authorization for the identified account."#))),
                );
    }
}

pub struct Config {
    pool: sqlx::PgPool,
    bus: Option<ActorRef<Bus>>,
}

impl Config {
    pub async fn from_env() -> anyhow::Result<Self> {
        let db_url = std::env::var("DATABASE_URL").expect("DATABASE_URL is required");

        let pool = sqlx::postgres::PgPoolOptions::new()
            .max_connections(10)
            .connect(&db_url)
            .await?;

        Ok(Self { pool, bus: None })
    }

    #[cfg(test)]
    pub fn test(pool: sqlx::PgPool) -> Self {
        Self { pool, bus: None }
    }

    #[cfg(test)]
    pub fn with_bus(self, bus: ActorRef<Bus>) -> Self {
        Self {
            bus: Some(bus),
            ..self
        }
    }

    pub fn into_router(self) -> Router {
        let bus = self.bus.unwrap_or_else(|| Bus::spawn(()));

        axum::Router::new()
            .route(
                "/api/v1/cardtypes",
                axum::routing::get(operations::list_card_types),
            )
            .route(
                "/api/v1/banners",
                axum::routing::post(operations::list_banners),
            )
            .route(
                "/api/v1/banners/{banner_id}",
                axum::routing::get(operations::get_banner),
            )
            .route(
                "/api/v1/banners/{banner_id}/pull",
                axum::routing::post(operations::pull_banner),
            )
            .route(
                "/api/v1/players/{player_id}/fields",
                axum::routing::get(operations::list_fields),
            )
            .route(
                "/api/v1/players/{player_id}/packs",
                axum::routing::post(operations::list_packs),
            )
            .route(
                "/api/v1/packs/{pack_id}/open",
                axum::routing::post(operations::open_pack),
            )
            .route("/play/ws", axum::routing::any(ws::v1))
            .layer(axum::middleware::from_fn(middleware::authorization::trust))
            .layer(axum::Extension(bus))
            .layer(axum::Extension(self.pool))
    }
}

pub async fn new() -> anyhow::Result<Router> {
    Ok(Config::from_env().await?.into_router())
}
