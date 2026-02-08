use crate::actor::player_socket::{Request, Response};
use crate::api::{self, ws::ProtocolV1Message};
use dioxus::fullstack::{get_server_url, WebsocketState};
use dioxus::prelude::*;
use futures::stream::{SplitSink, SplitStream};
use futures::{SinkExt, StreamExt};
#[cfg(feature = "web")]
use gloo::net::websocket::futures::WebSocket;
#[cfg(feature = "web")]
use gloo::net::websocket::Message;
use tokio::sync::Mutex;

#[cfg(feature = "web")]
pub struct CustomWebSocket {
    protocol: String,
    sender: Mutex<SplitSink<WebSocket, Message>>,
    receiver: Mutex<SplitStream<WebSocket>>,
}

#[derive(Copy, Clone)]
pub struct UseCustomWebsocket {
    waker: UseWaker<()>,
    #[cfg(feature = "web")]
    connection: Resource<anyhow::Result<CustomWebSocket>>,
    status: Signal<WebsocketState>,
    status_read: ReadSignal<WebsocketState>,
}

pub fn use_custom_websocket(path: &'static str) -> UseCustomWebsocket {
    let mut waker = use_waker();
    #[cfg(feature = "web")]
    let mut status = use_signal(|| WebsocketState::Connecting);
    #[cfg(not(feature = "web"))]
    let mut status = use_signal(|| WebsocketState::FailedToConnect);
    let status_read = use_hook(|| ReadSignal::new(status));

    #[cfg(feature = "web")]
    let connection = use_resource(move || async move {
        let socket = match gloo::net::websocket::futures::WebSocket::open_with_protocols(
            &format!("{}/{}", get_server_url(), path),
            &[api::ws::JSON_PROTOCOL, api::ws::MESSAGEPACK_PROTOCOL],
        ) {
            Ok(socket) => {
                status.set(WebsocketState::Open);
                socket
            }
            Err(error) => {
                status.set(WebsocketState::FailedToConnect);
                return Err(error.into());
            }
        };

        let protocol = socket.protocol();
        let (sender, receiver) = socket.split();

        waker.wake(());

        Ok(CustomWebSocket {
            protocol,
            sender: Mutex::new(sender),
            receiver: Mutex::new(receiver),
        })
    });

    UseCustomWebsocket {
        waker,
        #[cfg(feature = "web")]
        connection,
        status,
        status_read,
    }
}

impl UseCustomWebsocket {
    #[cfg(not(feature = "web"))]
    pub async fn connect(&self) -> WebsocketState {
        WebsocketState::FailedToConnect
    }

    #[cfg(feature = "web")]
    pub async fn connect(&self) -> WebsocketState {
        while !self.connection.finished() {
            _ = self.waker.wait().await;
        }
        self.status.cloned()
    }

    pub fn status(&self) -> ReadSignal<WebsocketState> {
        self.status_read
    }

    #[cfg(not(feature = "web"))]
    pub async fn send(&self, msg: ProtocolV1Message<Request>) -> anyhow::Result<()> {
        Err(anyhow::anyhow!("not implemented on this platform"))
    }

    #[cfg(not(feature = "web"))]
    pub async fn recv(&self) -> anyhow::Result<ProtocolV1Message<Response>> {
        Err(anyhow::anyhow!("not implemented on this platform"))
    }

    #[cfg(feature = "web")]
    pub async fn send(&self, msg: ProtocolV1Message<Request>) -> anyhow::Result<()> {
        self.connect().await;

        let connection = self.connection.as_ref();
        let connection = connection
            .as_deref()
            .ok_or_else(|| anyhow::anyhow!("websocket closed away"))?
            .as_ref()
            .map_err(|err| anyhow::anyhow!("{err}"))?;

        let msg = match connection.protocol.as_str() {
            api::ws::MESSAGEPACK_PROTOCOL => rmp_serde::to_vec(&msg).map(Message::Bytes)?,
            _ => serde_json::to_string(&msg).map(Message::Text)?,
        };

        connection.sender.lock().await.send(msg).await?;

        Ok(())
    }

    #[cfg(feature = "web")]
    pub async fn recv(&self) -> anyhow::Result<ProtocolV1Message<Response>> {
        self.connect().await;

        let connection = self.connection.as_ref();
        let connection = connection
            .as_deref()
            .ok_or_else(|| anyhow::anyhow!("websocket closed away"))?
            .as_ref()
            .map_err(|err| anyhow::anyhow!("{err}"))?;

        let mut recv = connection.receiver.lock().await;
        match recv.next().await {
            Some(Ok(Message::Text(text))) => Ok(serde_json::from_str(&text)?),
            Some(Ok(Message::Bytes(bytes))) => Ok(rmp_serde::from_read(&*bytes)?),
            Some(Err(e)) => Err(e.into()),
            None => anyhow::bail!("closed away"),
        }
    }
}
