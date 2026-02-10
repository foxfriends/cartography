use crate::actor::player_socket::{Request, Response};
use crate::api::ws::{self, ProtocolV1Message};
use crate::app::hooks::use_custom_websocket::{self, UseCustomWebsocket, use_custom_websocket};

#[cfg(not(feature = "messagepack"))]
type Encoding = use_custom_websocket::Json;
#[cfg(not(feature = "messagepack"))]
const PROTOCOL: &str = ws::JSON_PROTOCOL;

#[cfg(feature = "messagepack")]
type Encoding = use_custom_websocket::MessagePack;
#[cfg(feature = "messagepack")]
const PROTOCOL: &str = ws::MESSAGEPACK_PROTOCOL;

pub fn use_game_websocket()
-> UseCustomWebsocket<ProtocolV1Message<Request>, ProtocolV1Message<Response>, Encoding> {
    use_custom_websocket("play/ws", &[PROTOCOL])
}
