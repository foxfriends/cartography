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
            a { href: "/cards", "See the cards" }
            a { href: "/play", "Just Play" }
            a { href: "/demo", "Try Demo" }
        }
    }
}
