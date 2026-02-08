use crate::app::hooks::use_custom_websocket::use_custom_websocket;
use dioxus::prelude::*;

#[component]
pub fn Play() -> Element {
    let socket = use_custom_websocket("play/ws");

    use_future(move || async move {
        while let Ok(msg) = socket.recv().await {
            dbg!(msg);
        }
    });

    rsx! {
        main { display: "flex",
            div {
            }
        }
    }
}
