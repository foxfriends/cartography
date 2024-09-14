<script lang="ts">
  import GameWindow from "$lib/game/GameWindow.svelte";
  import Hud from "$lib/hud/Hud.svelte";
  import Tutorial from "$lib/tutorial/Tutorial.svelte";

  const geography = {
    biome: "Coast",
    origin: { x: 0, y: 0 },
    terrain: [
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Soil" },
        { type: "Soil" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Soil" },
        { type: "Soil" },
        { type: "Soil" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Soil" },
        { type: "Soil" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
    ],
    resources: [],
  };

  const deck = [
    { id: "waterwell1", type: "water-well" },
    { id: "bakery1", type: "bakery" },
    { id: "wheatfarm1", type: "wheat-farm" },
    { id: "cats1", type: "cat-neighbourhood" },
    { id: "cats2", type: "cat-neighbourhood" },
  ];

  let field = $state([{ id: "cats1", x: 2, y: 2 }]);
</script>

<main>
  <GameWindow bind:field {geography} {deck} />
</main>
<div>
  <Hud />
</div>

<Tutorial />

<style>
  main,
  div {
    position: absolute;
    inset: 0;
    width: 100vw;
    height: 100vh;
  }

  div {
    pointer-events: none;
  }

  :global(html) {
    overscroll-behavior: none;
  }
</style>
