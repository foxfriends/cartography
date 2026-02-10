use std::marker::PhantomData;

use dioxus::fullstack::{get_server_url, WebsocketState};
use dioxus::prelude::*;
use futures::stream::{SplitSink, SplitStream};
use futures::{SinkExt, StreamExt};
#[cfg(feature = "web")]
use gloo::net::websocket::futures::WebSocket;
#[cfg(feature = "web")]
use gloo::net::websocket::Message;
use serde::de::DeserializeOwned;
use serde::Serialize;
use tokio::sync::Mutex;

#[cfg(feature = "web")]
pub struct CustomWebSocket {
    protocol: String,
    sender: Mutex<SplitSink<WebSocket, Message>>,
    receiver: Mutex<SplitStream<WebSocket>>,
}

pub struct UseCustomWebsocket<In, Out, Enc> {
    waker: UseWaker<()>,
    #[cfg(feature = "web")]
    connection: Resource<anyhow::Result<CustomWebSocket>>,
    status: Signal<WebsocketState>,
    status_read: ReadSignal<WebsocketState>,
    _pd: PhantomData<(In, Out, Enc)>,
}

pub struct WebsocketSender<In, Enc> {
    #[cfg(feature = "web")]
    sender: Mutex<SplitSink<WebSocket, Message>>,
    status: Signal<WebsocketState>,
    status_read: ReadSignal<WebsocketState>,
    _pd: PhantomData<(In, Enc)>,
}

pub struct WebsocketReceiver<Out, Enc> {
    #[cfg(feature = "web")]
    receiver: Mutex<SplitStream<WebSocket>>,
    status: Signal<WebsocketState>,
    status_read: ReadSignal<WebsocketState>,
    _pd: PhantomData<(Out, Enc)>,
}

impl<In, Out, Enc> Copy for UseCustomWebsocket<In, Out, Enc> {}
impl<In, Out, Enc> Clone for UseCustomWebsocket<In, Out, Enc> {
    fn clone(&self) -> Self {
        *self
    }
}

pub fn use_custom_websocket<
    In: Serialize + DeserializeOwned,
    Out: Serialize + DeserializeOwned,
    Enc: Encoding,
>(
    path: &'static str,
    protocols: &'static [&'static str],
) -> UseCustomWebsocket<In, Out, Enc> {
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
            protocols,
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
        _pd: PhantomData,
    }
}

pub trait Encoding {
    #[cfg(feature = "web")]
    fn encode<T: Serialize>(message: &T) -> anyhow::Result<Message>;

    #[cfg(feature = "web")]
    fn decode<T: DeserializeOwned>(message: Message) -> anyhow::Result<T>;
}

#[allow(dead_code)]
pub struct Json;

impl Encoding for Json {
    #[cfg(feature = "web")]
    fn encode<T: Serialize>(message: &T) -> anyhow::Result<Message> {
        Ok(serde_json::to_string(message).map(Message::Text)?)
    }

    #[cfg(feature = "web")]
    fn decode<T: DeserializeOwned>(message: Message) -> anyhow::Result<T> {
        match message {
            Message::Text(text) => Ok(serde_json::from_str(&text)?),
            Message::Bytes(_) => anyhow::bail!("expected text message"),
        }
    }
}

#[allow(dead_code)]
pub struct MessagePack;

impl Encoding for MessagePack {
    #[cfg(feature = "web")]
    fn encode<T: Serialize>(message: &T) -> anyhow::Result<Message> {
        Ok(rmp_serde::to_vec(message).map(Message::Bytes)?)
    }

    #[cfg(feature = "web")]
    fn decode<T: DeserializeOwned>(message: Message) -> anyhow::Result<T> {
        match message {
            Message::Bytes(bytes) => Ok(rmp_serde::from_slice(&bytes)?),
            Message::Text(_) => anyhow::bail!("expected binary message"),
        }
    }
}

impl<In: Serialize + DeserializeOwned, Out: Serialize + DeserializeOwned, Enc: Encoding>
    UseCustomWebsocket<In, Out, Enc>
{
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
    pub async fn send(&self, msg: In) -> anyhow::Result<()> {
        Err(anyhow::anyhow!("not implemented on this platform"))
    }

    #[cfg(not(feature = "web"))]
    pub async fn recv(&self) -> anyhow::Result<Out> {
        Err(anyhow::anyhow!("not implemented on this platform"))
    }

    #[cfg(feature = "web")]
    pub async fn send(&self, msg: In) -> anyhow::Result<()> {
        self.connect().await;

        let connection = self.connection.as_ref();
        let connection = connection
            .as_deref()
            .ok_or_else(|| anyhow::anyhow!("websocket closed away"))?
            .as_ref()
            .map_err(|err| anyhow::anyhow!("{err}"))?;
        let msg = Enc::encode(&msg)?;
        connection.sender.lock().await.send(msg).await?;

        Ok(())
    }

    #[cfg(feature = "web")]
    pub async fn recv(&self) -> anyhow::Result<Out> {
        self.connect().await;

        let connection = self.connection.as_ref();
        let connection = connection
            .as_deref()
            .ok_or_else(|| anyhow::anyhow!("websocket closed away"))?
            .as_ref()
            .map_err(|err| anyhow::anyhow!("{err}"))?;

        let mut recv = connection.receiver.lock().await;
        match recv.next().await {
            Some(Ok(msg)) => Ok(Enc::decode(msg)?),
            Some(Err(e)) => Err(e.into()),
            None => anyhow::bail!("closed away"),
        }
    }
}
