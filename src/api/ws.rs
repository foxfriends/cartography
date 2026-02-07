use dioxus::fullstack::{WebSocketOptions, Websocket};
use dioxus::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum Request {
    Authenticate(String),
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum Response {
    Authenticated(String),
}

#[get("/api/ws")]
pub async fn v1(options: WebSocketOptions) -> Result<Websocket<Request, Response>> {
    let socket = options.on_upgrade(move |socket| async move {
    });
    Ok(socket)
}
