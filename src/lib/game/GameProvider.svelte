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
</script>

{@render children()}
