use crate::api::list_card_types;
use crate::app::components::card_grid::CardGrid;
use crate::app::Route;
use dioxus::prelude::*;

#[manganis::css_module("src/app/cards.css")]
struct Css;

#[component]
pub fn Cards() -> Element {
    let cards = use_loader(list_card_types)?;
    rsx! {
        div { class: Css::gridarea,
            CardGrid { cards: cards() }
        }
    }
}

#[component]
pub fn CardsLayout() -> Element {
    rsx! {
        main { class: Css::layout,
            div { class: Css::controls,
                Link { class: Css::back_button.to_owned(), to: Route::Menu {}, "← Back" }
                div { class: Css::fields,
                    input { r#type: "search", placeholder: "Search..." }
                }
            }
            ErrorBoundary { handle_error: |_| rsx! { "Failed to load cards, reload to try again" },
                SuspenseBoundary { fallback: |_| rsx! { "Cards loading" }, Outlet::<Route> {} }
            }
        }
    }
}
