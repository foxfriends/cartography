use dioxus::prelude::*;

mod menu;
mod play;

use menu::Menu;
use play::Play;

const MAIN_CSS: Asset = asset!("/assets/main.css");

#[derive(Debug, Clone, Routable, PartialEq)]
enum Route {
    #[route("/")]
    Menu {},
    #[route("/play")]
    Play {},
}

#[component]
pub fn App() -> Element {
    rsx! {
        document::Link { rel: "stylesheet", href: MAIN_CSS }
        Router::<Route> {}
    }
}
