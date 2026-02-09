use crate::db::TileCategory;
use crate::dto::CardType;
use dioxus::prelude::*;

#[manganis::css_module("src/app/components/card_grid.css")]
struct Css;

#[derive(Props, PartialEq, Clone)]
pub struct CardGridProps {
    cards: Vec<CardType>,
}

impl CardType {
    fn id(&self) -> &str {
        match self {
            CardType::Tile(tile_type) => &tile_type.id,
            CardType::Citizen(species) => &species.id,
        }
    }

    fn category(&self) -> &'static str {
        match self {
            CardType::Tile(tile_type) => match tile_type.category {
                TileCategory::Residential => "Residential",
                TileCategory::Production => "Production",
                TileCategory::Amenity => "Amenity",
                TileCategory::Source => "Source",
                TileCategory::Trade => "Trade",
                TileCategory::Transportation => "Transportation",
            },
            CardType::Citizen(..) => "Citizen",
        }
    }
}

#[component]
pub fn CardGrid(props: CardGridProps) -> Element {
    rsx! {
        div { class: Css::grid,
            for card in props.cards {
                div { class: Css::card,
                    div { class: Css::title, {format!("{} | {}", card.id(), card.category())} }
                    div { class: Css::image }
                    div { class: Css::info }
                }
            }
        }
    }
}

//   {#if card.category === "residential"}
//     {#each card.population as pop (pop.species)}
//       <p>
//         Houses {pop.quantity}
//         <SpeciesRef id={pop.species} plural={pop.quantity !== 1} />
//       </p>
//     {/each}
//   {:else if card.category === "production"}
//     {#each card.inputs as input (input.resource)}
//       <p>
//         Consumes {input.quantity}
//         <ResourceRef id={input.resource} />
//       </p>
//     {/each}
//     {#each card.outputs as output (output.resource)}
//       <p>
//         Produces {output.quantity}
//         <ResourceRef id={output.resource} />
//       </p>
//     {/each}
//   {:else if card.category === "source"}
//     {#each card.source as source (source)}
//       {#if source.type === "any"}
//         <p>Produces anywhere</p>
//       {/if}
//       {#if source.type === "terrain"}
//         <p>Produces on <TerrainRef id={source.terrain} /></p>
//       {/if}
//     {/each}
//     {#each card.outputs as output (output.resource)}
//       <p>
//         Yields {output.quantity}
//         <ResourceRef id={output.resource} />
//       </p>
//     {/each}
//   {/if}
