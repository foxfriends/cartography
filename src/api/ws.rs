use axum::extract::ws::{CloseFrame, Message, WebSocket, WebSocketUpgrade};
use futures::StreamExt;
use serde::{Deserialize, Serialize};
use tokio::sync::mpsc::{unbounded_channel, UnboundedSender};
use tokio_stream::wrappers::UnboundedReceiverStream;
use tracing::Instrument;

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "#type", content = "#payload")]
pub enum Request {
    Authenticate(String),
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "#type", content = "#payload")]
pub enum Response {
    Authenticated(String),
}

const JSON_PROTOCOL: &str = "v1-json.cartography.app";
const MESSAGEPACK_PROTOCOL: &str = "v1-messagepack.cartography.app";

impl std::error::Error for ProtocolV1Error {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            Self::InvalidJson(error) => Some(error),
            Self::InvalidMessagepack(error) => Some(error),
            _ => None,
        }
    }
}

#[derive(Debug, derive_more::Display)]
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
    Closed(CloseFrame),
}

async fn on_message(tx: UnboundedSender<Response>, message: Request) {}

pub async fn v1(ws: WebSocketUpgrade) -> axum::response::Response {
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
        let result = ws_receiver
            .filter_map(|msg| async move { msg.ok() })
            .map(|msg| match msg {
                Message::Text(text) if protocol == JSON_PROTOCOL => Some(
                    serde_json::from_str::<Request>(&text).map_err(ProtocolV1Error::InvalidJson),
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
            .flat_map_unordered(None, |msg| {
                let (tx, rx) = unbounded_channel::<Response>();
                tokio::spawn(on_message(tx, msg));
                UnboundedReceiverStream::new(rx)
            })
            .map(|response| match protocol.as_str() {
                MESSAGEPACK_PROTOCOL => rmp_serde::to_vec(&response)
                    .map(Message::from)
                    .map_err(axum::Error::new),
                _ => serde_json::to_string(&response)
                    .map(Message::from)
                    .map_err(axum::Error::new),
            })
            .forward(ws_sender)
            .in_current_span()
            .await;
        if let Err(error) = result {
            tracing::error!("websocket ended in error: {}", error);
        }
        tracing::debug!("websocket disconnected");
    })
}
