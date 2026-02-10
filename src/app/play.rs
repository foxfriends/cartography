use crate::actor::player_socket::Request;
use crate::app::hooks::use_game_websocket::use_game_websocket;
use dioxus::prelude::*;

#[component]
pub fn Play() -> Element {
    let socket = use_game_websocket();

    use_future(move || async move {
        socket
            .send(Request::Authenticate("foxfriends".to_owned()).into())
            .await
            .unwrap();
    });

    #[cfg(feature = "web")]
    use_future(move || async move {
        while let Ok(msg) = socket.recv().await {
            gloo::console::log!("msg:", format!("{:?}", msg));
        }
    });

    rsx! {
        main { display: "flex",
            div {
            }
        }
    }
}
