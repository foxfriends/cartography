use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[cfg(feature = "server")]
use axum::extract::ws::{CloseFrame, Message, WebSocket, WebSocketUpgrade};
#[cfg(feature = "server")]
use axum::Extension;
#[cfg(feature = "server")]
use futures::StreamExt;
#[cfg(feature = "server")]
use kameo::prelude::*;
#[cfg(feature = "server")]
use sqlx::PgPool;
#[cfg(feature = "server")]
use tracing::Instrument;
#[cfg(feature = "server")]
use crate::actor::player_socket::{PlayerSocket, Request, Response};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ProtocolV1Message<T> {
    id: Uuid,
    #[serde(flatten)]
    data: T,
}

pub const JSON_PROTOCOL: &str = "v1-json.cartography.app";
pub const MESSAGEPACK_PROTOCOL: &str = "v1-messagepack.cartography.app";

#[cfg(feature = "server")]
#[derive(Debug, derive_more::Error, derive_more::Display)]
enum ProtocolV1Error {
    #[display("invalid JSON payload: {_0}")]
    InvalidJson(serde_json::Error),
    #[display("invalid MessagePack payload: {_0}")]
    InvalidMessagepack(rmp_serde::decode::Error),
    #[display("invalid websocket message type")]
    InvalidMessage,
    #[display("client disconnected")]
    Disconnected,
    #[display("client closed connection: {_0:?}")]
    Closed(#[error(not(source))] CloseFrame),
}

#[cfg(feature = "server")]
pub async fn v1(ws: WebSocketUpgrade, db: Extension<PgPool>) -> axum::response::Response {
    let ws = ws.protocols([JSON_PROTOCOL, MESSAGEPACK_PROTOCOL]);
    let protocol = ws
        .selected_protocol()
        .and_then(|hv| hv.to_str().ok())
        .unwrap_or(JSON_PROTOCOL)
        .to_owned();
    ws.on_upgrade(move |socket: WebSocket| async move {
        let _span = tracing::info_span!("websocket connection");
        tracing::debug!("websocket connected");
        let (ws_sender, ws_receiver) = socket.split();
        futures::pin_mut!(ws_sender);

        let actor = PlayerSocket::spawn(PlayerSocket::build((*db).clone()));
        let result = ws_receiver
            .filter_map(|msg| async move { msg.ok() })
            .map(|msg| match msg {
                Message::Text(text) if protocol == JSON_PROTOCOL => Some(
                    serde_json::from_str::<ProtocolV1Message<Request>>(&text)
                        .map_err(ProtocolV1Error::InvalidJson),
                )
                .transpose(),
                Message::Binary(binary) if protocol == MESSAGEPACK_PROTOCOL => {
                    rmp_serde::from_read(binary.as_ref())
                        .map_err(ProtocolV1Error::InvalidMessagepack)
                }
                Message::Text(_) | Message::Binary(_) => Err(ProtocolV1Error::InvalidMessage),
                Message::Close(None) => Err(ProtocolV1Error::Disconnected),
                Message::Close(Some(frame)) => Err(ProtocolV1Error::Closed(frame)),
                _ => Ok(None),
            })
            .filter_map(|msg| async move {
                match msg {
                    Ok(None) => None,
                    Ok(Some(msg)) => {
                        tracing::trace!("websocket message: {:?}", msg);
                        Some(msg)
                    }
                    Err(error) => {
                        tracing::error!("websocket received error: {}", error);
                        None
                    }
                }
            })
            .filter_map({
                let actor = actor.clone();
                move |ProtocolV1Message { id, data }| {
                    let actor = actor.clone();
                    async move {
                        Some(
                            PlayerSocket::push(actor, data)
                                .await
                                .ok()?
                                .map(move |data| ProtocolV1Message { id, data }),
                        )
                    }
                }
            })
            .flatten_unordered(None)
            .map(
                |response: ProtocolV1Message<Response>| match protocol.as_str() {
                    MESSAGEPACK_PROTOCOL => rmp_serde::to_vec(&response)
                        .map(Message::from)
                        .map_err(axum::Error::new),
                    _ => serde_json::to_string(&response)
                        .map(Message::from)
                        .map_err(axum::Error::new),
                },
            )
            .forward(ws_sender)
            .in_current_span()
            .await;
        if let Err(error) = result {
            tracing::error!("websocket ended in error: {}", error);
        }
        if let Err(error) = actor.stop_gracefully().await {
            tracing::error!("failed to signal player socket to stop: {}", error);
        }
        actor.wait_for_shutdown().await;
        tracing::debug!("websocket disconnected");
    })
}
