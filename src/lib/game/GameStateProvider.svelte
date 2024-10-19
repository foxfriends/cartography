<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import type { Geography } from "$lib/types";
  import { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
  import type { Deck, DeckCard } from "$lib/engine/DeckCard";
  import type { FieldCard } from "$lib/engine/FieldCard";
  import type { Pack } from "$lib/engine/Pack";
  import { createCitizen, type Citizen } from "$lib/engine/Citizen";
  import type { Employment } from "$lib/engine/Employment";
  import type { Flow } from "$lib/engine/Flow";
  import { cards } from "$lib/data/cards";
  import type { BuyPackEvent } from "$lib/events/BuyPackEvent";
  import { generateCardId } from "$lib/engine/Card";
  import { choose } from "$lib/algorithm/choose";
  import type { CreateFlowEvent } from "$lib/events/CreateFlowEvent";
  import type { DeleteFlowEvent } from "$lib/events/DeleteFlowEvent";

  interface Shop {
    packs: Pack[];
  }

  interface GameState {
    readonly deck: Deck;
    readonly geography: Geography;
    readonly citizens: Citizen[];
    readonly employment: Employment[];
    readonly field: FieldCard[];
    readonly flow: Flow[];
    readonly shop: Shop;
    money: number;
  }

  const GAME_STATE = Symbol("GAME_STATE");

  export function getGameState(): GameState {
    return getContext(GAME_STATE);
  }
</script>

<script lang="ts">
  const { children }: { children: Snippet } = $props();

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
        { type: "grass" },
      ],
      [
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "soil" },
        { type: "soil" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
      ],
      [
        { type: "grass" },
        { type: "grass" },
        { type: "soil" },
        { type: "soil" },
        { type: "soil" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
      ],
      [
        { type: "grass" },
        { type: "grass" },
        { type: "soil" },
        { type: "soil" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
      ],
      [
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
      ],
      [
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
      ],
      [
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
      ],
      [
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
        { type: "grass" },
      ],
    ],
  } as const satisfies Geography;

  let deck: Deck = $state([]);
  let field: FieldCard[] = $state([]);
  let citizens: Citizen[] = $state([]);
  let employment: Employment[] = $state([]);
  let shop: Shop = $state({ packs: [] });
  let flow: Flow[] = $state([]);
  let money: number = $state(0);

  $effect.pre(() => {
    const storedState = window.localStorage.getItem("game_state");
    if (!storedState) return;
    try {
      ({ field, deck, flow, citizens, employment, shop, money } = JSON.parse(storedState));
    } catch {
      /* empty */
    }
  });

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
    },
  } satisfies GameState);

  $effect(() => {
    window.localStorage.setItem(
      "game_state",
      JSON.stringify({ field, deck, flow, citizens, employment, shop, money }),
    );
  });

  function oncardsreceived(event: CardsReceivedEvent) {
    for (const { id, type } of event.cards) {
      const card = cards[type];
      if (card.category === "residential") {
        for (const population of card.population) {
          citizens.push(
            ...Array.from({ length: population.quantity }, () =>
              createCitizen(id, population.species),
            ),
          );
        }
      }
    }
    deck.push(...event.cards);
  }

  function onbuypack(event: BuyPackEvent) {
    if (event.pack.price > money) return;

    const allCards = Object.values(cards);
    const contents: DeckCard[] = event.pack.contents
      .map((content) => {
        switch (content.type) {
          case "card":
            if (content.missing) return undefined;
            return { id: generateCardId(), type: content.card };
          case "category":
            return {
              id: generateCardId(),
              type: choose(allCards.filter((card) => card.category === content.category)).type,
            };
          case "any":
            return { id: generateCardId(), type: choose(allCards).type };
        }
      })
      .filter((card) => card !== undefined);

    money -= event.pack.price;
    window.dispatchEvent(new CardsReceivedEvent(contents));
  }

  function oncreateflow(event: CreateFlowEvent) {
    if (event.flow.source === event.flow.destination) return;

    const source = deck.find((card) => card.id === event.flow.source);
    if (!source) return;
    const sourceType = cards[source.type];
    if (!("outputs" in sourceType)) return;
    if (!sourceType.outputs.some((output) => output.resource === event.flow.resource)) return;

    const destination = deck.find((card) => card.id === event.flow.destination);
    if (!destination) return;
    const destinationType = cards[destination.type];
    if (!("inputs" in destinationType)) return;
    if (!destinationType.inputs.some((input) => input.resource === event.flow.resource)) return;

    if (
      flow.some(
        (flow) =>
          flow.source === event.flow.source &&
          flow.destination === event.flow.destination &&
          flow.resource === event.flow.resource,
      )
    ) {
      return;
    }

    flow.push(event.flow);
  }

  function ondeleteflow(event: DeleteFlowEvent) {
    const index = flow.findIndex((flow) => flow.id === event.flow);
    if (index !== -1) flow.splice(index, 1);
  }
</script>

<svelte:window {oncardsreceived} {onbuypack} {oncreateflow} {ondeleteflow} />

{@render children()}
