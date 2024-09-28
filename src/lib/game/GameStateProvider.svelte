<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import type { Geography } from "$lib/types";
  import { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
  import type { Deck, DeckCard } from "$lib/engine/DeckCard";
  import type { Field } from "$lib/engine/FieldCard";
  import type { Pack } from "$lib/engine/Pack";
  import { cards } from "$lib/data/cards";
  import type { BuyPackEvent } from "$lib/events/BuyPackEvent";
  import { generateCardId } from "$lib/engine/Card";
  import { choose } from "$lib/algorithm/choose";

  interface Shop {
    packs: Pack[];
  }

  interface GameState {
    readonly deck: Deck;
    readonly geography: Geography;
    readonly field: Field;
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
    resources: [],
  } as const satisfies Geography;

  let deck: Deck = $state([]);
  let field: Field = $state([]);
  let money: number = $state(0);
  let shop: Shop = $state({ packs: [] });

  $effect.pre(() => {
    const storedState = window.localStorage.getItem("game_state");
    if (!storedState) return;
    try {
      ({ field, deck, shop, money } = JSON.parse(storedState));
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
    get money() {
      return money;
    },
    get shop() {
      return shop;
    },
    set money(qty) {
      money = qty;
    },
  } satisfies GameState);

  $effect(() => {
    window.localStorage.setItem("game_state", JSON.stringify({ field, deck, shop, money }));
  });

  function oncardsreceived(event: CardsReceivedEvent) {
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
</script>

<svelte:window {oncardsreceived} {onbuypack} />

{@render children()}
