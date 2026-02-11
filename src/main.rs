mod actor;
mod api;
mod db;
mod dto;

use std::net::IpAddr;

use axum::{response::Html, Extension, Json};
use utoipa::OpenApi;
use utoipa_scalar::Scalar;

#[derive(OpenApi)]
#[openapi(
    paths(api::list_card_types::list_card_types),
    tags((name = "Global", description = "Publicly available global data about the Cartography game.")),
)]
struct ApiDoc;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let db_url = std::env::var("DATABASE_URL").expect("DATABASE_URL is required");
    let host: IpAddr = std::env::var("HOST")
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
    let app = axum::Router::new()
        .route(
            "/api/v1/cardtypes",
            axum::routing::get(api::list_card_types::list_card_types),
        )
        .route("/play/ws", axum::routing::any(api::ws::v1))
        .route(
            "/api/openapi.json",
            axum::routing::get(Json(ApiDoc::openapi())),
        )
        .route(
            "/api",
            axum::routing::get(Html(Scalar::new(ApiDoc::openapi()).to_html())),
        )
        .layer(Extension(pool));
    let listener = tokio::net::TcpListener::bind((host, port)).await?;
    axum::serve(listener, app).await?;
    Ok(())
}
