<script lang="ts">
  import CardGrid from "$lib/components/CardGrid.svelte";
  import { cards, type Card } from "$lib/data/cards";
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import type { DeckCard } from "$lib/types";
  import HudPanel from "./HudPanel.svelte";

  let { deck, field } = getGameState();

  let deckDialog: HudPanel | undefined = $state();
  let deckCards = $derived(
    deck
      .filter(({ id }) => !field.some((f) => f.id === id))
      .map((deckCard) => ({ ...cards[deckCard.type], deckCard })),
  );

  function onClickDeck() {
    deckDialog?.show();
    window.dispatchEvent(new CustomEvent("deckopen"));
  }

  function onSelectCard(card: Card & { deckCard: DeckCard }) {
    field.push({ id: card.deckCard.id, x: 0, y: 0, loose: true });
    deckDialog?.close();
  }

  function resetTutorial() {
    window.localStorage.removeItem("tutorial_step");
  }
</script>

<div class="area">
  <div class="menu" role="toolbar">
    <a class="button" href="/">Menu</a>
    <button onclick={resetTutorial}>Help</button>
    <button onclick={onClickDeck}>Deck</button>
  </div>
</div>

<HudPanel bind:this={deckDialog}>
  <article class="deck">
    <CardGrid cards={deckCards} {onSelectCard} />
  </article>
</HudPanel>

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

  .deck {
    padding: 2rem;
    --card-grid-gap: 2rem;
  }
</style>
