<script lang="ts">
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import type { Deck } from "$lib/types";

  let { deck, field } = getGameState();

  function onClickDeck() {
    const next = deck.find((d) => !field.some((f) => f.id === d.id));
    if (!next) return;
    field.push({ id: next.id, x: 50, y: 50, loose: true });
  }
</script>

<div class="area">
  <div class="menu">
    <a class="button" href="/">Menu</a>
    <button onclick={onClickDeck}>Deck</button>
  </div>
</div>

<style>
  .area {
    pointer-events: none;
    position: relative;
    width: 100%;
    height: 100%;
    display: grid;

    grid-template:
      ". ." 1fr
      ". menu" auto
      / 1fr auto;
  }

  .menu {
    grid-area: menu;
    padding: 2rem;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  button,
  a.button {
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 100%;
    width: 4rem;
    height: 4rem;
    background-color: rgb(0 0 0 / 0.7);
    backdrop-filter: blur(5px);
    color: white;
    pointer-events: auto;
    cursor: pointer;
    border: 1px solid rgb(0 0 0 / 0.12);
    box-shadow: 0 0 0.25rem rgb(0 0 0 / 0.25);
  }
</style>
