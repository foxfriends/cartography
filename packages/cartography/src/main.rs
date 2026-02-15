#[cfg(test)]
mod test;

mod actor;
mod api;
mod app;
mod bus;
mod db;
mod dto;

use clap::Parser as _;
use tracing_subscriber::prelude::*;
use utoipa::OpenApi as _;

#[derive(clap::Parser)]
struct Args {
    #[clap(long)]
    openapi: bool,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let args = Args::parse();

    if args.openapi {
        println!("{}", app::ApiDoc::openapi().to_pretty_json().unwrap());
        std::process::exit(0);
    }

    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .with(tracing_subscriber::fmt::layer().pretty())
        .init();

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

    let app = app::new()
        .await?
        .layer(tower_http::trace::TraceLayer::new_for_http());

    let listener = tokio::net::TcpListener::bind((host, port)).await?;
    axum::serve(listener, app).await?;
    Ok(())
}
