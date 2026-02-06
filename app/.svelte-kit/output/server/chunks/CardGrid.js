import "clsx";
import { Z as attr_style, Y as attr_class, _ as attr, W as ensure_array_like } from "./index2.js";
import { e as escape_html } from "./escaping.js";
const cards = {
  "trading-centre": { type: "trading-centre", name: "Trading Centre", category: "trade" },
  "trading-post": { type: "trading-post", name: "Trading Post", category: "trade" },
  "cat-neighbourhood": {
    type: "cat-neighbourhood",
    name: "Cat Neighbourhood",
    category: "residential",
    population: [{ quantity: 6, species: "cat" }]
  },
  "rabbit-neighbourhood": {
    type: "rabbit-neighbourhood",
    name: "Rabbit Neighbourhood",
    category: "residential",
    population: [{ quantity: 6, species: "rabbit" }]
  },
  "water-well": {
    type: "water-well",
    name: "Water Well",
    category: "source",
    employees: 1,
    source: [{ type: "any" }],
    outputs: [{ resource: "water", quantity: 10 }]
  },
  "wheat-farm": {
    type: "wheat-farm",
    name: "Wheat Farm",
    category: "source",
    employees: 4,
    source: [{ type: "terrain", terrain: "soil" }],
    outputs: [{ resource: "wheat", quantity: 4 }]
  },
  "lettuce-farm": {
    type: "lettuce-farm",
    name: "Lettuce Farm",
    category: "source",
    employees: 4,
    source: [{ type: "terrain", terrain: "soil" }],
    outputs: [{ resource: "lettuce", quantity: 4 }]
  },
  "tomato-farm": {
    type: "tomato-farm",
    name: "Tomato Farm",
    category: "source",
    employees: 4,
    source: [{ type: "terrain", terrain: "soil" }],
    outputs: [{ resource: "tomato", quantity: 4 }]
  },
  "flour-mill": {
    type: "flour-mill",
    name: "Flour Mill",
    category: "production",
    employees: 2,
    inputs: [{ resource: "wheat", quantity: 1 }],
    outputs: [{ resource: "flour", quantity: 5 }]
  },
  bakery: {
    type: "bakery",
    name: "Bakery",
    category: "production",
    employees: 2,
    inputs: [
      { resource: "water", quantity: 1 },
      { resource: "flour", quantity: 4 }
    ],
    outputs: [{ resource: "bread", quantity: 5 }]
  },
  "salad-shop": {
    type: "salad-shop",
    name: "Salad Shop",
    category: "production",
    employees: 2,
    inputs: [
      { resource: "tomato", quantity: 1 },
      { resource: "lettuce", quantity: 2 }
    ],
    outputs: [{ resource: "salad", quantity: 3 }]
  }
};
const resources = {
  water: {
    type: "water",
    name: "Water",
    value: 0
  },
  wheat: {
    type: "wheat",
    name: "Wheat",
    value: 1
  },
  lettuce: {
    type: "lettuce",
    name: "Lettuce",
    value: 1
  },
  tomato: {
    type: "tomato",
    name: "Tomato",
    value: 1
  },
  flour: {
    type: "flour",
    name: "Flour",
    value: 2
  },
  bread: {
    type: "bread",
    name: "Bread",
    value: 3
  },
  salad: {
    type: "salad",
    name: "Salad",
    value: 3
  }
};
function Shimmer($$renderer, $$props) {
  const { style, children } = $$props;
  $$renderer.push(`<span${attr_style(style)} class="shimmer svelte-j4afnf">`);
  children?.($$renderer);
  $$renderer.push(`<!----></span>`);
}
function ResourceRef($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { id } = $$props;
    const resource = resources[id];
    Shimmer($$renderer2, {
      style: "--shimmer-color: var(--color-resource)",
      children: ($$renderer3) => {
        $$renderer3.push(`<!---->${escape_html(resource.name)}`);
      }
    });
  });
}
const species = {
  cat: {
    type: "cat",
    name: "Cat",
    namePlural: "Cats",
    needs: [{ type: "resource", resource: "bread", quantity: 1 }]
  },
  rabbit: {
    type: "rabbit",
    name: "Rabbit",
    namePlural: "Rabbits",
    needs: [{ type: "resource", resource: "salad", quantity: 1 }]
  }
};
function SpeciesRef($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { id, plural = false } = $$props;
    const specie = species[id];
    Shimmer($$renderer2, {
      style: "--shimmer-color: var(--color-species)",
      children: ($$renderer3) => {
        $$renderer3.push(`<!---->${escape_html(plural ? specie.namePlural : specie.name)}`);
      }
    });
  });
}
const terrains = {
  soil: {
    type: "soil",
    name: "Soil"
  },
  grass: {
    type: "grass",
    name: "Grass"
  }
};
function TerrainRef($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { id } = $$props;
    const terrain = terrains[id];
    Shimmer($$renderer2, {
      style: "--shimmer-color: var(--color-terrain)",
      children: ($$renderer3) => {
        $$renderer3.push(`<!---->${escape_html(terrain.name)}`);
      }
    });
  });
}
function Card($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { card, onSelect, disabled = false } = $$props;
    $$renderer2.push(`<div${attr_class("card svelte-1udyrqm", void 0, { "selectable": !disabled && onSelect, "disabled": disabled })} role="button"${attr("tabindex", !disabled && onSelect ? 0 : void 0)}><div class="title svelte-1udyrqm">${escape_html(card.name)} | ${escape_html(card.category)}</div> <div class="image svelte-1udyrqm"></div> <div class="info svelte-1udyrqm">`);
    if (card.category === "residential") {
      $$renderer2.push("<!--[-->");
      $$renderer2.push(`<!--[-->`);
      const each_array = ensure_array_like(card.population);
      for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
        let pop = each_array[$$index];
        $$renderer2.push(`<p>Houses ${escape_html(pop.quantity)} `);
        SpeciesRef($$renderer2, { id: pop.species, plural: pop.quantity !== 1 });
        $$renderer2.push(`<!----></p>`);
      }
      $$renderer2.push(`<!--]-->`);
    } else {
      $$renderer2.push("<!--[!-->");
      if (card.category === "production") {
        $$renderer2.push("<!--[-->");
        $$renderer2.push(`<!--[-->`);
        const each_array_1 = ensure_array_like(card.inputs);
        for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
          let input = each_array_1[$$index_1];
          $$renderer2.push(`<p>Consumes ${escape_html(input.quantity)} `);
          ResourceRef($$renderer2, { id: input.resource });
          $$renderer2.push(`<!----></p>`);
        }
        $$renderer2.push(`<!--]--> <!--[-->`);
        const each_array_2 = ensure_array_like(card.outputs);
        for (let $$index_2 = 0, $$length = each_array_2.length; $$index_2 < $$length; $$index_2++) {
          let output = each_array_2[$$index_2];
          $$renderer2.push(`<p>Produces ${escape_html(output.quantity)} `);
          ResourceRef($$renderer2, { id: output.resource });
          $$renderer2.push(`<!----></p>`);
        }
        $$renderer2.push(`<!--]-->`);
      } else {
        $$renderer2.push("<!--[!-->");
        if (card.category === "source") {
          $$renderer2.push("<!--[-->");
          $$renderer2.push(`<!--[-->`);
          const each_array_3 = ensure_array_like(card.source);
          for (let $$index_3 = 0, $$length = each_array_3.length; $$index_3 < $$length; $$index_3++) {
            let source = each_array_3[$$index_3];
            if (source.type === "any") {
              $$renderer2.push("<!--[-->");
              $$renderer2.push(`<p>Produces anywhere</p>`);
            } else {
              $$renderer2.push("<!--[!-->");
            }
            $$renderer2.push(`<!--]--> `);
            if (source.type === "terrain") {
              $$renderer2.push("<!--[-->");
              $$renderer2.push(`<p>Produces on `);
              TerrainRef($$renderer2, { id: source.terrain });
              $$renderer2.push(`<!----></p>`);
            } else {
              $$renderer2.push("<!--[!-->");
            }
            $$renderer2.push(`<!--]-->`);
          }
          $$renderer2.push(`<!--]--> <!--[-->`);
          const each_array_4 = ensure_array_like(card.outputs);
          for (let $$index_4 = 0, $$length = each_array_4.length; $$index_4 < $$length; $$index_4++) {
            let output = each_array_4[$$index_4];
            $$renderer2.push(`<p>Yields ${escape_html(output.quantity)} `);
            ResourceRef($$renderer2, { id: output.resource });
            $$renderer2.push(`<!----></p>`);
          }
          $$renderer2.push(`<!--]-->`);
        } else {
          $$renderer2.push("<!--[!-->");
        }
        $$renderer2.push(`<!--]-->`);
      }
      $$renderer2.push(`<!--]-->`);
    }
    $$renderer2.push(`<!--]--></div></div>`);
  });
}
function Grid($$renderer, $$props) {
  const { items, item } = $$props;
  $$renderer.push(`<div class="grid svelte-1hhz0mg"><!--[-->`);
  const each_array = ensure_array_like(items);
  for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
    let data = each_array[$$index];
    item($$renderer, data);
    $$renderer.push(`<!---->`);
  }
  $$renderer.push(`<!--]--></div>`);
}
function CardGrid($$renderer, $$props) {
  const { cards: cards2, card } = $$props;
  {
    let item = function($$renderer2, data) {
      if (card) {
        $$renderer2.push("<!--[-->");
        card($$renderer2, data);
        $$renderer2.push(`<!---->`);
      } else {
        $$renderer2.push("<!--[!-->");
        Card($$renderer2, { card: data });
      }
      $$renderer2.push(`<!--]-->`);
    };
    Grid($$renderer, { items: cards2, item });
  }
}
export {
  CardGrid as C,
  Grid as G,
  ResourceRef as R,
  Shimmer as S,
  TerrainRef as T,
  Card as a,
  SpeciesRef as b,
  cards as c,
  resources as r,
  species as s
};
