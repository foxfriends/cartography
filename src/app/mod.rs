use dioxus::prelude::*;

mod cards;
mod components;
mod hooks;
mod menu;
mod play;

use cards::{Cards, CardsLayout};
use menu::Menu;
use play::Play;

const MAIN_CSS: Asset = asset!("/assets/main.css");

#[derive(Debug, Clone, Routable, PartialEq)]
enum Route {
    #[route("/")]
    Menu {},
    #[layout(CardsLayout)]
    #[route("/cards")]
    Cards {},
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
