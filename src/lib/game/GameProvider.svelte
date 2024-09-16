<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import type { Deck, Field, Geography } from "$lib/types";

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

  const deck = [
    { id: "cats1", type: "cat-neighbourhood" },
    { id: "waterwell1", type: "water-well" },
    { id: "bakery1", type: "bakery" },
    { id: "wheatfarm1", type: "wheat-farm" },
  ] as const satisfies Deck;

  let field: Field = $state([]);

  $effect.pre(() => {
    const storedState = window.localStorage.getItem("field_state");
    if (!storedState) return;
    try {
      field = JSON.parse(storedState);
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
    window.localStorage.setItem("field_state", JSON.stringify(field));
  });
</script>

{@render children()}
