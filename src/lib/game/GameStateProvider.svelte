<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import type { Geography } from "$lib/types";
  import type { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
  import type { Deck } from "$lib/engine/DeckCard";
  import type { Field } from "$lib/engine/FieldCard";

  interface GameState {
    readonly deck: Deck;
    readonly geography: Geography;
    readonly field: Field;
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

  $effect.pre(() => {
    const storedState = window.localStorage.getItem("game_state");
    if (!storedState) return;
    try {
      ({ field, deck, money } = JSON.parse(storedState));
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
    set money(qty) {
      money = qty;
    },
  } satisfies GameState);

  $effect(() => {
    window.localStorage.setItem("game_state", JSON.stringify({ field, deck, money }));
  });

  function oncardsreceived(event: CardsReceivedEvent) {
    deck.push(...event.cards);
  }
</script>

<svelte:window {oncardsreceived} />

{@render children()}
