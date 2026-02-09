mod actor;
mod api;
mod app;
mod db;
mod dto;

use crate::app::App;

fn main() {
    #[cfg(not(feature = "server"))]
    dioxus::fullstack::set_server_url(env!("SERVER_URL"));

    #[cfg(not(feature = "server"))]
    dioxus::launch(App);

    #[cfg(feature = "server")]
    dioxus::serve(|| async move {
        use dioxus::server::axum::Extension;

        let db_url = std::env::var("DATABASE_URL").expect("DATABASE_URL is required");
        let pool = sqlx::postgres::PgPoolOptions::new()
            .max_connections(10)
            .connect(&db_url)
            .await?;

        let router = dioxus::server::router(App)
            .route("/play/ws", axum::routing::any(api::ws::v1))
            .layer(Extension(pool));
        Ok(router)
    });
}
