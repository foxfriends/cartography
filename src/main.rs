mod actor;
mod api;
mod bus;
mod db;
mod dto;

use kameo::actor::Spawn as _;
use tracing_subscriber::prelude::*;
use utoipa::OpenApi as _;

#[derive(utoipa::OpenApi)]
#[openapi(
    paths(
        api::list_card_types::list_card_types,
        api::list_banners::list_banners,
        api::list_fields::list_fields,
    ),
    tags((name = "Global", description = "Publicly available global data about the Cartography game.")),
)]
struct ApiDoc;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .with(tracing_subscriber::fmt::layer().pretty())
        .init();

    let db_url = std::env::var("DATABASE_URL").expect("DATABASE_URL is required");
    let host: std::net::IpAddr = std::env::var("HOST")
        .as_deref()
        .unwrap_or("0.0.0.0")
        .parse()
        .expect("HOST must be a valid IP address");
    let port = std::env::var("PORT")
        .as_deref()
        .unwrap_or("12000")
        .parse()
        .expect("PORT must be a valid u16");
    let pool = sqlx::postgres::PgPoolOptions::new()
        .max_connections(10)
        .connect(&db_url)
        .await?;

    let bus = bus::Bus::spawn(());
    let app = axum::Router::new()
        .route(
            "/api/v1/cardtypes",
            axum::routing::get(api::list_card_types::list_card_types),
        )
        .route(
            "/api/v1/banners",
            axum::routing::post(api::list_banners::list_banners),
        )
        .route(
            "/api/v1/players/{player_id}/fields",
            axum::routing::get(api::list_fields::list_fields),
        )
        .route("/play/ws", axum::routing::any(api::ws::v1))
        .route(
            "/api/openapi.json",
            axum::routing::get(axum::response::Json(ApiDoc::openapi())),
        )
        .route(
            "/api",
            axum::routing::get(axum::response::Html(
                utoipa_scalar::Scalar::new(ApiDoc::openapi()).to_html(),
            )),
        )
        .layer(axum::Extension(bus))
        .layer(axum::Extension(pool))
        .layer(tower_http::trace::TraceLayer::new_for_http());
    let listener = tokio::net::TcpListener::bind((host, port)).await?;
    axum::serve(listener, app).await?;
    Ok(())
}
