<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import type { Deck, Field, Geography } from "$lib/types";
  import type { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";

  type GameState = {
    deck: Deck;
    geography: Geography;
    field: Field;
  };

  export function getGameState(): GameState {
    return getContext("gamestate");
  }
</script>

<script lang="ts">
  let { children }: { children: Snippet } = $props();

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

  $effect.pre(() => {
    const storedState = window.localStorage.getItem("game_state");
    if (!storedState) return;
    try {
      ({ field, deck } = JSON.parse(storedState));
    } catch {
      /* empty */
    }
  });

  setContext("gamestate", {
    get geography() {
      return geography;
    },
    get deck() {
      return deck;
    },
    get field() {
      return field;
    },
  } satisfies GameState);

  $effect(() => {
    window.localStorage.setItem("game_state", JSON.stringify({ field, deck }));
  });

  function oncardsreceived(event: CardsReceivedEvent) {
    deck.push(...event.cards);
  }
</script>

<svelte:window {oncardsreceived} />

{@render children()}
