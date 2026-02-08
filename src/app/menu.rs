use crate::app::Route;
use dioxus::prelude::*;

#[component]
pub fn Menu() -> Element {
    rsx! {
        main {
            display: "flex",
            width: "100%",
            height: "100vh",
            flex_direction: "column",
            align_items: "center",
            justify_content: "center",
            gap: "1rem",

            h1 { font_size: "2rem", "This game?" }
            Link { to: Route::Cards {}, "See the cards" }
            Link { to: Route::Play {}, "Just Play" }
            Link { to: Route::Menu {}, "Try Demo" }
        }
    }
}
