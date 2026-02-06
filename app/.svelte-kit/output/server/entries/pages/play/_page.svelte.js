import "clsx";
import { s as setContext, g as getContext } from "../../../chunks/context.js";
import { c as cards, s as species, r as resources, R as ResourceRef, a as Card, C as CardGrid, S as Shimmer, G as Grid, b as SpeciesRef, T as TerrainRef } from "../../../chunks/CardGrid.js";
import { W as ensure_array_like, X as bind_props, Y as attr_class, Z as attr_style, _ as attr, $ as stringify, a0 as clsx } from "../../../chunks/index2.js";
import { e as escape_html } from "../../../chunks/escaping.js";
import { D as DragTile, G as GridLines } from "../../../chunks/GridLines.js";
import { D as DragWindow } from "../../../chunks/DragWindow.js";
function apply(...args) {
  return (handler) => () => handler(...args);
}
const APP_STATE = /* @__PURE__ */ Symbol("APP_STATE");
function getAppState() {
  return getContext(APP_STATE);
}
function AppStateProvider($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { children } = $$props;
    let mode = "place";
    setContext(APP_STATE, {
      get mode() {
        return mode;
      },
      set mode(newMode) {
        mode = newMode;
      }
    });
    children($$renderer2);
    $$renderer2.push(`<!---->`);
  });
}
class CardsReceivedEvent extends Event {
  cards;
  constructor(cards2) {
    super("cardsreceived");
    this.cards = cards2;
  }
}
function sourceIsProducing({ card, field }, geography) {
  return card.source.some((source) => {
    switch (source.type) {
      case "terrain":
        if (geography.terrain[field.y]?.[field.x]?.type === source.terrain) {
          return true;
        }
        break;
      case "any":
        return true;
    }
  });
}
function canProduce(card) {
  return card.category === "source" || card.category === "production";
}
function generateCardId() {
  return window.crypto.randomUUID();
}
const GAME_STATE = /* @__PURE__ */ Symbol("GAME_STATE");
function getGameState() {
  return getContext(GAME_STATE);
}
function GameStateProvider($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { children } = $$props;
    const geography = {
      biome: "Coast",
      origin: { x: 0, y: 0 },
      terrain: [
        [
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" }
        ],
        [
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "soil" },
          { type: "soil" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" }
        ],
        [
          { type: "grass" },
          { type: "grass" },
          { type: "soil" },
          { type: "soil" },
          { type: "soil" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" }
        ],
        [
          { type: "grass" },
          { type: "grass" },
          { type: "soil" },
          { type: "soil" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" }
        ],
        [
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" }
        ],
        [
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" }
        ],
        [
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" }
        ],
        [
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" },
          { type: "grass" }
        ]
      ]
    };
    let deck = [];
    let field = [];
    let citizens = [];
    let employment = [];
    let shop = { packs: [] };
    let flow = [];
    let money = 0;
    setContext(GAME_STATE, {
      get geography() {
        return geography;
      },
      get deck() {
        return deck;
      },
      get field() {
        return field;
      },
      get shop() {
        return shop;
      },
      get flow() {
        return flow;
      },
      get citizens() {
        return citizens;
      },
      get employment() {
        return employment;
      },
      get money() {
        return money;
      },
      set money(qty) {
        money = qty;
      }
    });
    children($$renderer2);
    $$renderer2.push(`<!---->`);
  });
}
function indexById$1(field) {
  return new Map(field.map((card) => [card.id, card]));
}
function indexById(field) {
  return new Map(field.map((card) => [card.id, card]));
}
function indexByPosition(field) {
  const index = [];
  for (const card of field) {
    index[card.y] ??= [];
    index[card.y][card.x] = card;
  }
  return {
    get(x, y) {
      return index[y]?.[x];
    }
  };
}
function indexByDestination(flows) {
  return Map.groupBy(flows, (flow) => flow.destination);
}
function add(a, b) {
  return a + b;
}
const RESOURCE_STATE = /* @__PURE__ */ Symbol("RESOURCE_STATE");
function getResourceState() {
  return getContext(RESOURCE_STATE);
}
function ResourceStateProvider($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { children } = $$props;
    const gameState = getGameState();
    const { deck, field, flow, geography } = gameState;
    const deckById = indexById$1(deck);
    const fieldById = indexById(field);
    indexByPosition(field);
    const flowGraph = indexByDestination(flow);
    const cardsOnField = field.filter((fc) => !fc.loose);
    const population = cardsOnField.map((field2) => deckById.get(field2.id)).map((deck2) => cards[deck2.type]).filter((card) => card.category === "residential").flatMap((card) => card.population).reduce(
      (population2, residence) => {
        population2[residence.species] ??= { quantity: 0 };
        population2[residence.species].quantity += residence.quantity;
        return population2;
      },
      {}
    );
    const cardProduction = (() => {
      const cardProduction2 = {};
      const remaining = new Map(Array.from(flowGraph.entries()).filter(([, inputs]) => inputs.length).map(([id, inputs]) => [id, [...inputs]]));
      const producing = cardsOnField.filter((field2) => canProduce(cards[deckById.get(field2.id).type])).filter((field2) => !flowGraph.get(field2.id)?.length).map((field2) => field2.id);
      nextCard: while (producing.length) {
        const currentId = producing.shift();
        const currentField = fieldById.get(currentId);
        const currentDeck = deckById.get(currentId);
        const currentCard = cards[currentDeck.type];
        for (const [id, flows] of remaining.entries()) {
          const left = flows.filter((flow2) => flow2.source === currentId);
          if (left.length) {
            remaining.set(id, left);
          } else {
            remaining.delete(id);
            producing.push(id);
          }
        }
        const inputs = [];
        switch (currentCard.category) {
          case "production": {
            const sources = flowGraph.get(currentId);
            const tentativeInputs = currentCard.inputs.map((input) => {
              const consumeFrom = [];
              let remaining2 = input.quantity;
              if (sources) {
                for (const flow2 of sources) {
                  const producerOutput = cardProduction2[flow2.source]?.outputs;
                  if (!producerOutput) continue;
                  for (const output of producerOutput) {
                    if (output.resource !== input.resource) continue;
                    const outputLeft = output.quantity - output.consumedBy.map((consumer) => consumer.quantity).reduce(add, 0);
                    if (remaining2 <= outputLeft) {
                      consumeFrom.push({ flow: flow2, output, quantity: remaining2 });
                      remaining2 = 0;
                      break;
                    } else {
                      consumeFrom.push({ flow: flow2, output, quantity: outputLeft });
                      remaining2 -= outputLeft;
                    }
                  }
                }
              }
              return { input, remaining: remaining2, consumeFrom };
            });
            if (!tentativeInputs.every((input) => input.remaining === 0)) continue nextCard;
            for (const input of tentativeInputs) {
              for (const { flow: flow2, output, quantity } of input.consumeFrom) {
                output.consumedBy.push({ id: currentId, quantity });
                inputs.push({ cardId: flow2.source, resource: output.resource, quantity });
              }
            }
            break;
          }
          case "source": {
            if (!sourceIsProducing({ card: currentCard, field: currentField }, geography)) {
              continue nextCard;
            }
            break;
          }
          case "residential":
          case "trade":
            continue nextCard;
          default:
            throw new Error("Unreachable");
        }
        cardProduction2[currentId] = {
          inputs,
          outputs: currentCard.outputs.map((output) => ({ ...output, consumedBy: [] }))
        };
      }
      return cardProduction2;
    })();
    const resourceProduction = (() => {
      const resourceProduction2 = Object.values(cardProduction).flatMap((card) => card.outputs).reduce(
        (resourceProduction3, output) => {
          resourceProduction3[output.resource] ??= { produced: 0, consumed: 0, demand: 0 };
          resourceProduction3[output.resource].produced += output.quantity;
          for (const { quantity } of output.consumedBy) {
            resourceProduction3[output.resource].consumed += quantity;
          }
          return resourceProduction3;
        },
        {}
      );
      for (const [specie, { quantity }] of Object.entries(population)) {
        for (const need of species[specie].needs) {
          if (need.type !== "resource") continue;
          resourceProduction2[need.resource] ??= { produced: 0, consumed: 0, demand: 0 };
          resourceProduction2[need.resource].demand += quantity * need.quantity;
        }
      }
      return resourceProduction2;
    })();
    const income = Object.entries(resourceProduction).map(([resource, { produced, consumed, demand }]) => {
      const value = resources[resource].value;
      return value * Math.max(0, produced - consumed - demand) + value * 5 * Math.min(demand, Math.max(0, produced - consumed));
    }).reduce(add, 0);
    setContext(RESOURCE_STATE, {
      get population() {
        return population;
      },
      get cardProduction() {
        return cardProduction;
      },
      get resourceProduction() {
        return resourceProduction;
      },
      get income() {
        return income;
      }
    });
    children($$renderer2);
    $$renderer2.push(`<!---->`);
  });
}
class CardFocusEvent extends Event {
  cardId;
  constructor(cardId) {
    super("cardfocus");
    this.cardId = cardId;
  }
}
function CardTile($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { id, type: cardType, x, y, loose = false, onMove } = $$props;
    const appState = getAppState();
    function onclick() {
      window.dispatchEvent(new CardFocusEvent(id));
    }
    const cardSymbol = cards[cardType].name.split(" ").map((word) => word[0]).join("");
    DragTile($$renderer2, {
      onMove: appState.mode === "place" ? onMove : void 0,
      onClick: onclick,
      x,
      y,
      loose,
      children: ($$renderer3) => {
        $$renderer3.push(`<div class="card svelte-isv3d4">${escape_html(cardSymbol)}</div>`);
      }
    });
  });
}
function CardField($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { field = void 0, deck, onMoveCard } = $$props;
    $$renderer2.push(`<!--[-->`);
    const each_array = ensure_array_like(field);
    for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
      let card = each_array[$$index];
      const deckCard = deck.find((dc) => dc.id === card.id);
      if (deckCard) {
        $$renderer2.push("<!--[-->");
        CardTile($$renderer2, {
          id: card.id,
          x: card.x,
          y: card.y,
          type: deckCard.type,
          onMove: (x, y) => onMoveCard(card.id, x, y),
          loose: card.loose
        });
      } else {
        $$renderer2.push("<!--[!-->");
      }
      $$renderer2.push(`<!--]-->`);
    }
    $$renderer2.push(`<!--]-->`);
    bind_props($$props, { field });
  });
}
class CardPlacedEvent extends Event {
  card;
  constructor(card) {
    super("cardplaced");
    this.card = card;
  }
}
class DeleteFlowEvent extends Event {
  flow;
  constructor(flow) {
    super("deleteflow");
    this.flow = flow;
  }
}
function FlowLine($$renderer, $$props) {
  const TILE_SIZE = 128;
  const TOP_RANGE = TILE_SIZE * 2;
  const MAX_RANGE = TILE_SIZE * 5;
  const { onclick, x1, y1, x2, y2 } = $$props;
  const id = `${x1}_${y1}_${x2}_${y2}`;
  const dx = x2 - x1;
  const dy = y2 - y1;
  const l = Math.sqrt(dx ** 2 + dy ** 2);
  const r = l / 2;
  const a = Math.atan2(dy, dx);
  const sx = Math.sign(dx);
  const sy = Math.sign(dy);
  const s = Math.sign(dx) || 1;
  const qx = x1 + dx / 2 + r * Math.sin(a) / 2 * s;
  const qy = y1 + dy / 2 - r * Math.cos(a) / 2 * s;
  const qx2 = x1 + dx / 2 + (r + 12) * Math.sin(a) / 2 * s;
  const qy2 = y1 + dy / 2 - (r + 12) * Math.cos(a) / 2 * s;
  const efficacy = 1 - Math.max(0, Math.min(1, (l - TOP_RANGE) / (MAX_RANGE - TOP_RANGE)) * 0.75);
  $$renderer.push(`<path role="button" tabindex="0"${attr_class("flow live svelte-da3do8", void 0, { "selectable": !!onclick })}${attr_style(`--efficacy: ${stringify(efficacy)}; fill: url(#${stringify(id)}); stroke: url(#${stringify(id)})`)}${attr("d", `M ${stringify(x1)} ${stringify(y1)} Q ${stringify(qx)} ${stringify(qy)} ${stringify(x2)} ${stringify(y2)} Q ${stringify(qx2)} ${stringify(qy2)} ${stringify(x1)} ${stringify(y1)}`)}></path><defs><linearGradient${attr("id", id)}${attr("x1", sx === -1 ? 1 : 0)}${attr("y1", sy === -1 ? 1 : 0)}${attr("x2", sx === -1 ? 0 : 1)}${attr("y2", sy === -1 ? 0 : 1)}><stop offset="0%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 100%, var(--color-input) 0%)"></stop><stop offset="10%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 90%, var(--color-input) 10%)"></stop><stop offset="20%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 80%, var(--color-input) 20%)"></stop><stop offset="30%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 70%, var(--color-input) 30%)"></stop><stop offset="40%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 60%, var(--color-input) 40%)"></stop><stop offset="50%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 50%, var(--color-input) 50%)"></stop><stop offset="60%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 40%, var(--color-input) 60%)"></stop><stop offset="70%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 30%, var(--color-input) 70%)"></stop><stop offset="80%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 20%, var(--color-input) 80%)"></stop><stop offset="90%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 10%, var(--color-input) 90%)"></stop><stop offset="100%" style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 0%, var(--color-input) 100%)"></stop></linearGradient></defs>`);
}
function ProductionOverlay($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { id, x, y, type: cardType, onStartFlow } = $$props;
    const cardSpec = cards[cardType];
    const inputs = {};
    const outputs = {};
    function findInput(resource) {
      return inputs[resource];
    }
    function findOutput(resource) {
      return outputs[resource];
    }
    $$renderer2.push(`<div class="gridspace svelte-go3dgf"${attr_style(`--grid-x: ${stringify(x)}; --grid-y: ${stringify(y)}`)}${attr("data-cardid", id)}>`);
    if ("inputs" in cardSpec) {
      $$renderer2.push("<!--[-->");
      $$renderer2.push(`<div class="pips svelte-go3dgf"><!--[-->`);
      const each_array = ensure_array_like(cardSpec.inputs);
      for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
        let input = each_array[$$index];
        $$renderer2.push(`<div class="piprow svelte-go3dgf"><div class="pip input svelte-go3dgf" role="presentation"></div> <span>${escape_html(input.quantity)} → `);
        ResourceRef($$renderer2, { id: input.resource });
        $$renderer2.push(`<!----></span></div>`);
      }
      $$renderer2.push(`<!--]--></div>`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> `);
    if ("outputs" in cardSpec) {
      $$renderer2.push("<!--[-->");
      $$renderer2.push(`<div class="pips svelte-go3dgf"><!--[-->`);
      const each_array_1 = ensure_array_like(cardSpec.outputs);
      for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
        let output = each_array_1[$$index_1];
        $$renderer2.push(`<div class="piprow svelte-go3dgf"><span>`);
        ResourceRef($$renderer2, { id: output.resource });
        $$renderer2.push(`<!----> → ${escape_html(output.quantity)}</span> <div class="pip output svelte-go3dgf" role="presentation"></div></div>`);
      }
      $$renderer2.push(`<!--]--></div>`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--></div>`);
    bind_props($$props, { findInput, findOutput });
  });
}
function CardFlow($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { flow, deck, field } = $$props;
    const validFlow = flow.map(({ source: sourceId, destination: destinationId, ...flow2 }) => {
      const source = field.find((card) => card.id === sourceId);
      const destination = field.find((card) => card.id === destinationId);
      if (!source || !destination) return void 0;
      return { ...flow2, source, destination };
    }).filter((flow2) => flow2 !== void 0).toSorted((a, b) => a.priority - b.priority);
    let clientHeight = 0;
    let clientWidth = 0;
    let draggingFlowSource = void 0;
    let clientX = 0;
    let clientY = 0;
    const overlays = {};
    function onStartFlow(event, card) {
      draggingFlowSource = {
        resource: event.resource,
        sourceType: event.sourceType,
        anchor: event.currentTarget,
        card
      };
      clientX = event.clientX;
      clientY = event.clientY;
    }
    function deleteFlow(id) {
      window.dispatchEvent(new DeleteFlowEvent(id));
    }
    $$renderer2.push(`<!--[-->`);
    const each_array = ensure_array_like(field);
    for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
      let card = each_array[$$index];
      const deckCard = deck.find((dc) => dc.id === card.id);
      ProductionOverlay($$renderer2, {
        id: card.id,
        type: deckCard.type,
        x: card.x,
        y: card.y,
        onStartFlow: (event) => onStartFlow(event, card)
      });
    }
    $$renderer2.push(`<!--]--> <div class="full svelte-13qno0"><svg${attr("viewBox", `0 0 ${stringify(clientWidth)} ${stringify(clientHeight)}`)}><!--[-->`);
    const each_array_1 = ensure_array_like(validFlow);
    for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
      let flow2 = each_array_1[$$index_1];
      const start = overlays[flow2.source.id]?.findOutput(flow2.resource)?.getBoundingClientRect();
      const end = overlays[flow2.destination.id]?.findInput(flow2.resource)?.getBoundingClientRect();
      if (start && end) {
        $$renderer2.push("<!--[-->");
        FlowLine($$renderer2, {
          x1: start.x + start.width / 2,
          y1: start.y + start.height / 2,
          x2: end.x + end.width / 2,
          y2: end.y + end.height / 2,
          onclick: () => deleteFlow(flow2.id)
        });
      } else {
        $$renderer2.push("<!--[!-->");
      }
      $$renderer2.push(`<!--]-->`);
    }
    $$renderer2.push(`<!--]-->`);
    if (draggingFlowSource) {
      $$renderer2.push("<!--[-->");
      const bbox = draggingFlowSource.anchor.getBoundingClientRect();
      const x = bbox.x + bbox.width / 2;
      const y = bbox.y + bbox.height / 2;
      FlowLine($$renderer2, { x1: x, y1: y, x2: clientX, y2: clientY });
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--></svg></div>`);
  });
}
function GameWindow($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const TILE_SIZE = 128;
    const appState = getAppState();
    const gameState = getGameState();
    const { geography, deck, field, flow } = gameState;
    let clientWidth = 0;
    let clientHeight = 0;
    let offsetX = 0;
    let offsetY = 0;
    function onMoveCard(id, movementX, movementY) {
      const card = field.find((card2) => card2.id === id);
      if (card) {
        const destinationX = card.loose ? Math.round((card.x + movementX) / TILE_SIZE) : card.x + Math.round(movementX / TILE_SIZE);
        const destinationY = card.loose ? Math.round((card.y + movementY) / TILE_SIZE) : card.y + Math.round(movementY / TILE_SIZE);
        if (field.some((card2) => card2.x === destinationX && card2.y === destinationY)) return;
        card.x = destinationX;
        card.y = destinationY;
        card.loose = false;
        window.dispatchEvent(new CardPlacedEvent(card));
      }
    }
    const xMin = Math.floor(offsetX / TILE_SIZE);
    const yMin = Math.floor(offsetY / TILE_SIZE);
    const xMax = Math.floor((offsetX + clientWidth) / TILE_SIZE) + 1;
    const yMax = Math.floor((offsetY + clientHeight) / TILE_SIZE) + 1;
    function isOnScreen({ x, y }) {
      if (clientWidth === 0 || clientHeight === 0) return false;
      return xMin <= x && x < xMax && yMin <= y && y < yMax;
    }
    const terrain = geography.terrain.slice(Math.max(0, yMin - geography.origin.y), Math.max(0, yMax - geography.origin.y)).flatMap((row, y) => row.slice(Math.max(0, xMin - geography.origin.x), Math.max(0, xMax - geography.origin.x)).map((col, x) => ({
      x: x + Math.max(xMin - geography.origin.x, 0),
      y: y + Math.max(yMin - geography.origin.y, 0),
      ...col
    })));
    const visibleField = field.filter((card) => card.loose || isOnScreen(card));
    const activeField = visibleField.filter((card) => !card.loose);
    let $$settled = true;
    let $$inner_renderer;
    function $$render_inner($$renderer3) {
      DragWindow($$renderer3, {
        get offsetX() {
          return offsetX;
        },
        set offsetX($$value) {
          offsetX = $$value;
          $$settled = false;
        },
        get offsetY() {
          return offsetY;
        },
        set offsetY($$value) {
          offsetY = $$value;
          $$settled = false;
        },
        get clientWidth() {
          return clientWidth;
        },
        set clientWidth($$value) {
          clientWidth = $$value;
          $$settled = false;
        },
        get clientHeight() {
          return clientHeight;
        },
        set clientHeight($$value) {
          clientHeight = $$value;
          $$settled = false;
        },
        children: ($$renderer4) => {
          $$renderer4.push(`<!--[-->`);
          const each_array = ensure_array_like(terrain);
          for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
            let tile = each_array[$$index];
            $$renderer4.push(`<div class="terrain svelte-11xczzg"${attr("data-type", tile.type)}${attr_style(`--grid-x: ${stringify(tile.x)}; --grid-y: ${stringify(tile.y)}`)}></div>`);
          }
          $$renderer4.push(`<!--]--> `);
          GridLines($$renderer4, {});
          $$renderer4.push(`<!----> `);
          CardField($$renderer4, { field: visibleField, deck, onMoveCard });
          $$renderer4.push(`<!----> `);
          if (appState.mode === "flow") {
            $$renderer4.push("<!--[-->");
            CardFlow($$renderer4, { field: activeField, deck, flow });
          } else {
            $$renderer4.push("<!--[!-->");
          }
          $$renderer4.push(`<!--]-->`);
        },
        $$slots: { default: true }
      });
    }
    do {
      $$settled = true;
      $$inner_renderer = $$renderer2.copy();
      $$render_inner($$inner_renderer);
    } while (!$$settled);
    $$renderer2.subsume($$inner_renderer);
  });
}
class CardFieldedEvent extends Event {
  card;
  constructor(card) {
    super("cardfielded");
    this.card = card;
  }
}
function CardFocusDialog($$renderer, $$props) {
  let card = void 0;
  function show(cardToShow) {
    card = cardToShow;
  }
  function close() {
  }
  $$renderer.push(`<dialog class="svelte-1ylobv7">`);
  if (card) {
    $$renderer.push("<!--[-->");
    Card($$renderer, { card });
  } else {
    $$renderer.push("<!--[!-->");
  }
  $$renderer.push(`<!--]--></dialog>`);
  bind_props($$props, { show, close });
}
function Row($$renderer, $$props) {
  const { items, item } = $$props;
  $$renderer.push(`<div class="row svelte-15gpl1s"><!--[-->`);
  const each_array = ensure_array_like(items);
  for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
    let data = each_array[$$index];
    item($$renderer, data);
    $$renderer.push(`<!---->`);
  }
  $$renderer.push(`<!--]--></div>`);
}
function ShimmerModal($$renderer, $$props) {
  const { children, style } = $$props;
  function show() {
  }
  function close() {
  }
  $$renderer.push(`<dialog${attr_style(style)} class="svelte-eun80g">`);
  children($$renderer);
  $$renderer.push(`<!----></dialog>`);
  bind_props($$props, { show, close });
}
function CardRewardDialog($$renderer, $$props) {
  let cards2 = [];
  function show(cardsToShow) {
    cards2 = cardsToShow;
  }
  ShimmerModal($$renderer, {
    style: "--shimmer-color: rgb(164 85 217)",
    children: ($$renderer2) => {
      $$renderer2.push(`<article class="svelte-t8l7ck"><header class="svelte-t8l7ck"><h1>Card Received!</h1></header> `);
      {
        let item = function($$renderer3, card) {
          $$renderer3.push(`<div class="card svelte-t8l7ck">`);
          Card($$renderer3, { card });
          $$renderer3.push(`<!----></div>`);
        };
        Row($$renderer2, { items: cards2, item });
      }
      $$renderer2.push(`<!----> <button>Sweet!</button></article>`);
    },
    $$slots: { default: true }
  });
  bind_props($$props, { show });
}
function Modal($$renderer, $$props) {
  const { children, sizing = "fit" } = $$props;
  function show() {
  }
  function close() {
  }
  $$renderer.push(`<dialog${attr_class(clsx(sizing), "svelte-ta60gp")}>`);
  children($$renderer);
  $$renderer.push(`<!----></dialog>`);
  bind_props($$props, { show, close });
}
class DeckOpenedEvent extends Event {
  constructor() {
    super("deckopened");
  }
}
function DeckDialog($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { onSelectCard } = $$props;
    const gameState = getGameState();
    const { deck, field } = gameState;
    const deckCards = deck.map((deckCard) => ({
      ...cards[deckCard.type],
      deckCard,
      isFielded: field.some((f) => f.id === deckCard.id)
    }));
    function show() {
      window.dispatchEvent(new DeckOpenedEvent());
    }
    function close() {
    }
    Modal($$renderer2, {
      sizing: "fill",
      children: ($$renderer3) => {
        $$renderer3.push(`<article><header class="svelte-rkzgio"><h1>Deck</h1> <button class="close svelte-rkzgio">×</button></header> <div class="content svelte-rkzgio">`);
        {
          let card = function($$renderer4, card2) {
            Card($$renderer4, {
              card: card2,
              onSelect: apply(card2)(onSelectCard),
              disabled: card2.isFielded
            });
          };
          CardGrid($$renderer3, { cards: deckCards, card });
        }
        $$renderer3.push(`<!----></div></article>`);
      },
      $$slots: { default: true }
    });
    bind_props($$props, { show, close });
  });
}
function MoneyRef($$renderer, $$props) {
  const { amount } = $$props;
  Shimmer($$renderer, {
    style: "--shimmer-color: oklch(from var(--color-money) calc(l - 0.2) c h)",
    children: ($$renderer2) => {
      if (amount !== void 0) {
        $$renderer2.push("<!--[-->");
        $$renderer2.push(`$${escape_html(amount)}`);
      } else {
        $$renderer2.push("<!--[!-->");
        $$renderer2.push(`Money`);
      }
      $$renderer2.push(`<!--]-->`);
    }
  });
}
function ProductionReport($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { resourceProduction } = $$props;
    const income = Object.entries(resourceProduction).map(([resource, { produced, consumed, demand }]) => {
      const value = resources[resource].value;
      return value * Math.max(0, produced - consumed - demand) + value * 5 * Math.min(demand, Math.max(0, produced - consumed));
    }).reduce(add, 0);
    $$renderer2.push(`<table class="svelte-mterps"><thead class="svelte-mterps"><tr class="svelte-mterps"><th class="svelte-mterps">Resource</th><th class="svelte-mterps">Produced</th><th class="svelte-mterps">Consumed</th><th class="svelte-mterps">Satisfaction</th><th class="svelte-mterps">Exported</th><th class="svelte-mterps">Value</th><th class="svelte-mterps">Profit</th></tr></thead><tbody><!--[-->`);
    const each_array = ensure_array_like(Object.entries(resourceProduction));
    for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
      let [resourceType, production] = each_array[$$index];
      const excess = Math.max(0, production.produced - production.consumed - production.demand);
      const satisfaction = Math.min(production.demand, Math.max(0, production.produced - production.consumed));
      const value = resources[resourceType].value;
      $$renderer2.push(`<tr class="svelte-mterps"><th class="svelte-mterps">`);
      ResourceRef($$renderer2, { id: resourceType });
      $$renderer2.push(`<!----></th><td class="produced svelte-mterps">${escape_html(production.produced)}</td><td class="consumed svelte-mterps">${escape_html(production.consumed)}</td><td class="svelte-mterps"><span class="produced svelte-mterps">${escape_html(satisfaction)}</span> / <span class="consumed svelte-mterps">${escape_html(production.demand)}</span></td><td class="consumed svelte-mterps">${escape_html(excess)}</td><td class="svelte-mterps">`);
      MoneyRef($$renderer2, { amount: value });
      $$renderer2.push(`<!----></td><td class="svelte-mterps">`);
      MoneyRef($$renderer2, { amount: value * excess + value * 5 * satisfaction });
      $$renderer2.push(`<!----></td></tr>`);
    }
    $$renderer2.push(`<!--]--></tbody><tfoot class="svelte-mterps"><tr class="svelte-mterps"><th class="svelte-mterps">Total</th><td class="svelte-mterps"></td><td class="svelte-mterps"></td><td class="svelte-mterps"></td><td class="svelte-mterps"></td><td class="svelte-mterps"></td><td class="svelte-mterps">`);
    MoneyRef($$renderer2, { amount: income });
    $$renderer2.push(`<!----></td></tr></tfoot></table>`);
  });
}
function ProductionReportDialog($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const resourceState = getResourceState();
    const { resourceProduction } = resourceState;
    function show() {
    }
    function close() {
    }
    Modal($$renderer2, {
      children: ($$renderer3) => {
        $$renderer3.push(`<article><header class="svelte-1dvzbw0"><h1>Production Report</h1> <button class="close svelte-1dvzbw0">×</button></header> <div class="content svelte-1dvzbw0">`);
        ProductionReport($$renderer3, { resourceProduction });
        $$renderer3.push(`<!----></div></article>`);
      },
      $$slots: { default: true }
    });
    bind_props($$props, { show, close });
  });
}
class ShopOpenedEvent extends Event {
  constructor() {
    super("shopopened");
  }
}
function CardBack($$renderer, $$props) {
  const { category } = $$props;
  $$renderer.push(`<div class="card-back svelte-legrwj">`);
  if (category) {
    $$renderer.push("<!--[-->");
    $$renderer.push(`<div class="category svelte-legrwj">${escape_html(category)}</div>`);
  } else {
    $$renderer.push("<!--[!-->");
  }
  $$renderer.push(`<!--]--></div>`);
}
function PackRef($$renderer, $$props) {
  const { children } = $$props;
  Shimmer($$renderer, {
    style: "--shimmer-color: var(--color-pack)",
    children: ($$renderer2) => {
      children($$renderer2);
      $$renderer2.push(`<!---->`);
    }
  });
}
function ShimmerBox($$renderer, $$props) {
  const { style, children } = $$props;
  $$renderer.push(`<div${attr_style(style)} class="shimmer svelte-y2bo7g">`);
  children?.($$renderer);
  $$renderer.push(`<!----></div>`);
}
function Pack($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { pack } = $$props;
    let hovering = false;
    $$renderer2.push(`<div class="pack svelte-1h5lzcn" role="button"${attr("tabindex", 0)}><div class="banner svelte-1h5lzcn">`);
    PackRef($$renderer2, {
      children: ($$renderer3) => {
        $$renderer3.push(`<!---->${escape_html(pack.name)}`);
      }
    });
    $$renderer2.push(`<!----></div> `);
    if (pack.description) {
      $$renderer2.push("<!--[-->");
      $$renderer2.push(`<div class="info svelte-1h5lzcn">${escape_html(pack.description)}</div>`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> `);
    if (pack.originalPrice) {
      $$renderer2.push("<!--[-->");
      $$renderer2.push(`<div class="price-tag replaced svelte-1h5lzcn">`);
      ShimmerBox($$renderer2, {
        style: "--shimmer-color: oklch(from var(--color-money) l calc(c - 0.075) h); border-radius: 1rem; padding-inline: 1rem;",
        children: ($$renderer3) => {
          $$renderer3.push(`<s class="price-label svelte-1h5lzcn">$${escape_html(pack.originalPrice)}</s>`);
        }
      });
      $$renderer2.push(`<!----></div>`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> <div${attr_class("price-tag svelte-1h5lzcn", void 0, { "replacement": !!pack.originalPrice })}>`);
    ShimmerBox($$renderer2, {
      style: "--shimmer-color: var(--color-money); border-radius: 1rem; padding-inline: 1rem;",
      children: ($$renderer3) => {
        $$renderer3.push(`<div class="price-label svelte-1h5lzcn">$${escape_html(pack.price)}</div>`);
      }
    });
    $$renderer2.push(`<!----></div></div> <dialog${attr("open", hovering, true)} class="tooltip svelte-1h5lzcn"><header class="svelte-1h5lzcn">`);
    PackRef($$renderer2, {
      children: ($$renderer3) => {
        $$renderer3.push(`<!---->${escape_html(pack.name)}`);
      }
    });
    $$renderer2.push(`<!----></header> `);
    {
      let item = function($$renderer3, content) {
        $$renderer3.push(`<div class="card svelte-1h5lzcn">`);
        if (content.type === "card") {
          $$renderer3.push("<!--[-->");
          Card($$renderer3, { card: cards[content.card], disabled: content.missing });
        } else {
          $$renderer3.push("<!--[!-->");
          if (content.type === "category") {
            $$renderer3.push("<!--[-->");
            CardBack($$renderer3, { category: content.category });
          } else {
            $$renderer3.push("<!--[!-->");
            if (content.type === "any") {
              $$renderer3.push("<!--[-->");
              CardBack($$renderer3, {});
            } else {
              $$renderer3.push("<!--[!-->");
            }
            $$renderer3.push(`<!--]-->`);
          }
          $$renderer3.push(`<!--]-->`);
        }
        $$renderer3.push(`<!--]--></div>`);
      };
      Row($$renderer2, { items: pack.contents, item });
    }
    $$renderer2.push(`<!----></dialog>`);
  });
}
function ShopDialog($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const gameState = getGameState();
    const { shop } = gameState;
    function show() {
      window.dispatchEvent(new ShopOpenedEvent());
    }
    function close() {
    }
    Modal($$renderer2, {
      sizing: "fill",
      children: ($$renderer3) => {
        $$renderer3.push(`<article><header class="svelte-1w43591"><h1>Shop</h1> <button class="close svelte-1w43591">×</button></header> <div class="content svelte-1w43591">`);
        {
          let item = function($$renderer4, pack) {
            Pack($$renderer4, { pack });
          };
          Grid($$renderer3, { items: shop.packs, item });
        }
        $$renderer3.push(`<!----></div></article>`);
      },
      $$slots: { default: true }
    });
    bind_props($$props, { show, close });
  });
}
function Hud($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const appState = getAppState();
    const gameState = getGameState();
    const { deck, field, money } = gameState;
    const resourceState = getResourceState();
    const { resourceProduction, income } = resourceState;
    const tradingCentre = deck.find((card) => card.type === "trading-centre");
    const tradingCentreOnField = field.find((card) => card.id === tradingCentre?.id);
    const hasTrade = tradingCentreOnField && !tradingCentreOnField.loose;
    function onSelectCard(card) {
      window.dispatchEvent(new CardFieldedEvent(card.deckCard));
      field.push({ id: card.deckCard.id, x: 0, y: 0, loose: true });
    }
    $$renderer2.push(`<div class="area svelte-og50z2"><div class="status svelte-og50z2"><div class="title-area svelte-og50z2"><span class="title svelte-og50z2">Your Town</span> <span>$${escape_html(money)}</span> <span>$${escape_html(income)} / day</span></div> <div class="resource-area svelte-og50z2"><!--[-->`);
    const each_array = ensure_array_like(Object.entries(resourceProduction));
    for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
      let [resource, { produced, consumed, demand }] = each_array[$$index];
      $$renderer2.push(`<span>`);
      ResourceRef($$renderer2, { id: resource });
      $$renderer2.push(`<!----> `);
      if (demand) {
        $$renderer2.push("<!--[-->");
        $$renderer2.push(`${escape_html(produced)}/${escape_html(demand)}`);
      } else {
        $$renderer2.push("<!--[!-->");
        $$renderer2.push(`${escape_html(produced - consumed)}`);
      }
      $$renderer2.push(`<!--]--></span>`);
    }
    $$renderer2.push(`<!--]--></div></div> <div class="menu svelte-og50z2" role="toolbar"><a class="button svelte-og50z2" href="/">Menu</a> <button class="svelte-og50z2">Reset</button> <button class="svelte-og50z2">Mode: ${escape_html(appState.mode)}</button> `);
    if (hasTrade) {
      $$renderer2.push("<!--[-->");
      $$renderer2.push(`<button class="svelte-og50z2">Prod</button> <button class="svelte-og50z2">Shop</button>`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> <button class="svelte-og50z2">Deck</button></div></div> `);
    ProductionReportDialog($$renderer2, {});
    $$renderer2.push(`<!----> `);
    DeckDialog($$renderer2, { onSelectCard });
    $$renderer2.push(`<!----> `);
    ShopDialog($$renderer2, {});
    $$renderer2.push(`<!----> `);
    CardRewardDialog($$renderer2, {});
    $$renderer2.push(`<!----> `);
    CardFocusDialog($$renderer2, {});
    $$renderer2.push(`<!---->`);
  });
}
function CardRef($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { id } = $$props;
    const card = cards[id];
    Shimmer($$renderer2, {
      style: "--shimmer-color: var(--color-card)",
      children: ($$renderer3) => {
        $$renderer3.push(`<!---->${escape_html(card.name)}`);
      }
    });
  });
}
function TutorialDialog($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { onDismiss, children, actions } = $$props;
    function show() {
    }
    function dismiss() {
      onDismiss?.();
    }
    $$renderer2.push(`<dialog class="svelte-1chcjmg"><article class="svelte-1chcjmg">`);
    children($$renderer2);
    $$renderer2.push(`<!----></article> <div class="controls svelte-1chcjmg">`);
    actions($$renderer2, dismiss);
    $$renderer2.push(`<!----></div></dialog>`);
    bind_props($$props, { show });
  });
}
function Tutorial($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const gameState = getGameState();
    const { deck, field, shop } = gameState;
    const resourceState = getResourceState();
    const { resourceProduction } = resourceState;
    function introReward() {
      window.setTimeout(
        () => {
          window.dispatchEvent(new CardsReceivedEvent([{ id: generateCardId(), type: "cat-neighbourhood" }]));
        },
        500
      );
    }
    function arrangeNeighbourhoodReward() {
      window.setTimeout(
        () => {
          window.dispatchEvent(new CardsReceivedEvent([{ id: generateCardId(), type: "bakery" }]));
        },
        500
      );
    }
    function placeBakeryReward() {
      window.setTimeout(
        () => {
          window.dispatchEvent(new CardsReceivedEvent([
            { id: generateCardId(), type: "water-well" },
            { id: generateCardId(), type: "wheat-farm" }
          ]));
        },
        500
      );
    }
    function aboutTradeReward() {
      window.setTimeout(
        () => {
          window.dispatchEvent(new CardsReceivedEvent([{ id: generateCardId(), type: "trading-centre" }]));
        },
        500
      );
    }
    function aboutIncomeReward() {
      gameState.money += 4;
      shop.packs.push({
        id: window.crypto.randomUUID(),
        name: "Starter Pack?",
        description: "A one of a kind pack containing all you need to get started!\nIt looks like this one has been opened already, and some of the cards are missing.",
        price: 4,
        originalPrice: 20,
        contents: [
          { type: "card", card: "cat-neighbourhood", missing: true },
          { type: "card", card: "water-well", missing: true },
          { type: "card", card: "wheat-farm", missing: true },
          { type: "card", card: "flour-mill" },
          { type: "card", card: "bakery", missing: true }
        ]
      });
    }
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>Of course!</button>`);
      };
      TutorialDialog($$renderer2, {
        onDismiss: introReward,
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>Hello mayor, and welcome to the location of our new town! All of us are just getting started
    here ourselves. We haven't even placed a single card yet!</p> <p>I have the card for a `);
          CardRef($$renderer3, { id: "cat-neighbourhood" });
          $$renderer3.push(`<!----> right here, I'll put it into your deck.
    Since you're in charge here, I'll let you see about setting that up for us. Start by opening up the
    deck view.</p> <p class="info svelte-1195hbs">The button to open the deck view is at the bottom right.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>Got it!</button>`);
      };
      TutorialDialog($$renderer2, {
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>This is the deck view; the cards you see here are yours. There are all sorts of cards to be
    collected, each one providing a different function. I'm sure you'll soon have a whole collection
    and turn this town into a great place to live!</p> <p>For now, we just need to set up that `);
          CardRef($$renderer3, { id: "cat-neighbourhood" });
          $$renderer3.push(`<!----> for your citizens to live
    in.</p> <p class="info svelte-1195hbs">Click a card to drop it into the world.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>On it!</button>`);
      };
      TutorialDialog($$renderer2, {
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>The `);
          CardRef($$renderer3, { id: "cat-neighbourhood" });
          $$renderer3.push(`<!----> is now on the field, but it's sitting loose. Make sure to
    properly set into the grid to ensure that it stays put.</p> <p class="info svelte-1195hbs">Click and drag cards to relocate them.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>Got it!</button>`);
      };
      TutorialDialog($$renderer2, {
        onDismiss: arrangeNeighbourhoodReward,
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>Residential cards provide housing for residents in your town. The `);
          CardRef($$renderer3, { id: "cat-neighbourhood" });
          $$renderer3.push(`<!----> in particular has room for 6 `);
          SpeciesRef($$renderer3, { id: "cat" });
          $$renderer3.push(`<!----> residents.</p> <p>Each type of resident has different needs. When the needs of a resident are satisfied, their
    productivity increases and they will pay you more `);
          MoneyRef($$renderer3, {});
          $$renderer3.push(`<!---->.</p> <p>A `);
          SpeciesRef($$renderer3, { id: "cat" });
          $$renderer3.push(`<!----> requires 1 `);
          ResourceRef($$renderer3, { id: "bread" });
          $$renderer3.push(`<!----> per day to be satisfied. Luckily,
    I have a `);
          CardRef($$renderer3, { id: "bakery" });
          $$renderer3.push(`<!----> card already, which will allow us to produce that `);
          ResourceRef($$renderer3, { id: "bread" });
          $$renderer3.push(`<!----> right here in town!</p> <p class="info svelte-1195hbs">Place a `);
          CardRef($$renderer3, { id: "bakery" });
          $$renderer3.push(`<!----> from your deck into your town.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>Ok!</button>`);
      };
      TutorialDialog($$renderer2, {
        onDismiss: placeBakeryReward,
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>The `);
          CardRef($$renderer3, { id: "bakery" });
          $$renderer3.push(`<!----> is a Production card. Production cards produce resources by consuming
    the resources of other cards nearby. To produce 5 units of `);
          ResourceRef($$renderer3, { id: "bread" });
          $$renderer3.push(`<!---->, the `);
          CardRef($$renderer3, { id: "bakery" });
          $$renderer3.push(`<!----> uses 1 unit of `);
          ResourceRef($$renderer3, { id: "water" });
          $$renderer3.push(`<!----> and 4 units of `);
          ResourceRef($$renderer3, { id: "flour" });
          $$renderer3.push(`<!---->.</p> <p>If we want this `);
          CardRef($$renderer3, { id: "bakery" });
          $$renderer3.push(`<!----> working, we'll need to get our hands on those resources.
    I think I have a few more cards that might help with that, take a look and see what you can do.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>Makes sense to me!</button>`);
      };
      TutorialDialog($$renderer2, {
        onDismiss: () => "await-production",
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>The `);
          CardRef($$renderer3, { id: "water-well" });
          $$renderer3.push(`<!----> and `);
          CardRef($$renderer3, { id: "wheat-farm" });
          $$renderer3.push(`<!----> cards are both Source cards, meaning
    they are able to produce resources without needing to consume anything first. Instead, they allow
    you to harvest resources straight from the source.</p> <p>While the `);
          CardRef($$renderer3, { id: "water-well" });
          $$renderer3.push(`<!----> is able to produce water from anywhere, the `);
          CardRef($$renderer3, { id: "wheat-farm" });
          $$renderer3.push(`<!----> requires being placed on fertile `);
          TerrainRef($$renderer3, { id: "soil" });
          $$renderer3.push(`<!----> in order to
    grow wheat.</p> <p class="info svelte-1195hbs">Make sure your new cards are both producing.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>Wow!</button>`);
      };
      TutorialDialog($$renderer2, {
        onDismiss: aboutTradeReward,
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>The `);
          CardRef($$renderer3, { id: "wheat-farm" });
          $$renderer3.push(`<!----> is producing, but without a `);
          CardRef($$renderer3, { id: "flour-mill" });
          $$renderer3.push(`<!----> in town,
    there's nothing for us to do with the `);
          ResourceRef($$renderer3, { id: "wheat" });
          $$renderer3.push(`<!---->.</p> <p>Luckily, I've got one last card here with me, it's a rare `);
          CardRef($$renderer3, { id: "trading-centre" });
          $$renderer3.push(`<!----> card. You'll
    probably never get your hands on another one of these. This `);
          CardRef($$renderer3, { id: "trading-centre" });
          $$renderer3.push(`<!----> will become the backbone of our town, allowing us to sell our excess resources in exchange for `);
          MoneyRef($$renderer3, {});
          $$renderer3.push(`<!---->.</p> <p class="info svelte-1195hbs">Place the `);
          CardRef($$renderer3, { id: "trading-centre" });
          $$renderer3.push(`<!---->.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>I do like money...</button>`);
      };
      TutorialDialog($$renderer2, {
        onDismiss: aboutIncomeReward,
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>This is a world of production and trade, so all resources are reported in a rate of <strong>production per day</strong>. Other than `);
          MoneyRef($$renderer3, {});
          $$renderer3.push(`<!---->, there's not much point in
    stockpiling any resources. Instead, at the end of each day, any excess resources we haven't used
    get exported via the `);
          CardRef($$renderer3, { id: "trading-centre" });
          $$renderer3.push(`<!---->.</p> <p>The `);
          CardRef($$renderer3, { id: "wheat-farm" });
          $$renderer3.push(`<!----> produces 4 `);
          ResourceRef($$renderer3, { id: "wheat" });
          $$renderer3.push(`<!----> per day, but a unit of `);
          ResourceRef($$renderer3, { id: "wheat" });
          $$renderer3.push(`<!----> is worth just `);
          MoneyRef($$renderer3, { amount: 1 });
          $$renderer3.push(`<!----> when exported. The `);
          ResourceRef($$renderer3, { id: "water" });
          $$renderer3.push(`<!----> on the other hand isn't even worth selling. Unused resources aren't worth
    much!</p> <p>Eventually most of your income will be coming from satisfied residents buying the things they
    need, but for now I'll just work out a deal real quick for your first export.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>Exciting!</button>`);
      };
      TutorialDialog($$renderer2, {
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>The other thing the `);
          CardRef($$renderer3, { id: "trading-centre" });
          $$renderer3.push(`<!----> allows you to trade for is more cards. For a
    little bit of `);
          MoneyRef($$renderer3, {});
          $$renderer3.push(`<!---->, you can buy a pack containing a few common cards which you can add
    to your town.</p> <p class="info svelte-1195hbs">Open up the shop with the button at the bottom right.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>That's ok...</button>`);
      };
      TutorialDialog($$renderer2, {
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>The shop offers new cards in <strong>Packs</strong>. The available packs are always changing,
    and each one contains a different assortment of cards, so be sure to check back often and buy
    any that catch your eye.</p> <p>There's one pack available right now, the `);
          PackRef($$renderer3, {
            children: ($$renderer4) => {
              $$renderer4.push(`<!---->Starter Pack`);
            }
          });
          $$renderer3.push(`<!---->, but I have a
    confession to make... I already opened it and gave you most of the cards. There's still one left
    though, I didn't want to take away all the fun!</p> <p class="info svelte-1195hbs">Buy (the rest of) the `);
          PackRef($$renderer3, {
            children: ($$renderer4) => {
              $$renderer4.push(`<!---->Starter Pack`);
            }
          });
          $$renderer3.push(`<!---->.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>Cool!</button>`);
      };
      TutorialDialog($$renderer2, {
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>There's just one last step: to set up the transportation of resources from where they are
    produced, to where they will be consumed. As the mayor, you're responsible for determining all
    of what goes where and how it gets there.</p> <p>In general, it's hard to move things long distances by hand in one day. One or two tiles is
    totally fine, but beyond that you'll be losing about 25% of the total throughput per tile. Any
    more than 5 tiles is too far for things to be carried by hand in a day at all, though you might
    be able find cards for useful tools to help with that type of thing later on.</p> <p class="info svelte-1195hbs">Enter Flow mode and drag connections from producers to consumers.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!----> `);
    {
      let actions = function($$renderer3, dismiss) {
        $$renderer3.push(`<button>I will!</button>`);
      };
      TutorialDialog($$renderer2, {
        actions,
        children: ($$renderer3) => {
          $$renderer3.push(`<p>That's it, the `);
          CardRef($$renderer3, { id: "bakery" });
          $$renderer3.push(`<!----> is finally able to make its `);
          ResourceRef($$renderer3, { id: "bread" });
          $$renderer3.push(`<!---->!
    You don't have to set up connections for residents finding and consuming their needs, or for
    resources to be exported, that all happens automatically, so you'll find that already your
    expected profits for tomorrow are looking quite healthy!</p> <p>You'll be on your own from here on out. I look forward to seeing where you take the town, and
    meeting all the people who will eventually move in! Good luck, and I hope you have fun!</p> <p class="info svelte-1195hbs">Cards don't only come from packs. Earn powerful and rare cards by participating in certain
    activities in the real world, or trade your cards online with other players to get exactly the
    ones you need.</p>`);
        },
        $$slots: { actions: true, default: true }
      });
    }
    $$renderer2.push(`<!---->`);
  });
}
function _page($$renderer) {
  $$renderer.push(`<div role="application" class="svelte-hy9bcf">`);
  AppStateProvider($$renderer, {
    children: ($$renderer2) => {
      GameStateProvider($$renderer2, {
        children: ($$renderer3) => {
          ResourceStateProvider($$renderer3, {
            children: ($$renderer4) => {
              $$renderer4.push(`<main class="svelte-hy9bcf">`);
              GameWindow($$renderer4);
              $$renderer4.push(`<!----></main> <div class="hud svelte-hy9bcf">`);
              Hud($$renderer4);
              $$renderer4.push(`<!----></div> `);
              Tutorial($$renderer4);
              $$renderer4.push(`<!---->`);
            }
          });
        }
      });
    }
  });
  $$renderer.push(`<!----></div>`);
}
export {
  _page as default
};
