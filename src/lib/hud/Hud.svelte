<script lang="ts">
  import { cards, type Card } from "$lib/data/cards";
  import { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
  import type { CardReceivedEvent } from "$lib/events/CardReceivedEvent";
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import type { DeckCard } from "$lib/types";
  import CardRewardDialog from "./CardRewardDialog.svelte";
  import DeckDialog from "./DeckDialog.svelte";

  let { field } = getGameState();

  let deckDialog: DeckDialog | undefined = $state();
  let cardRewardDialog: CardRewardDialog | undefined = $state();

  function onClickDeck() {
    deckDialog?.show();
  }

  function onSelectCard(card: Card & { deckCard: DeckCard }) {
    window.dispatchEvent(new CardFieldedEvent(card.deckCard));
    field.push({ id: card.deckCard.id, x: 0, y: 0, loose: true });
    deckDialog?.close();
  }

  function reset() {
    window.localStorage.clear();
    window.location.reload();
  }

  function oncardreceived(event: CardReceivedEvent) {
    const card = cards[event.card.type];
    cardRewardDialog?.show([card]);
  }
</script>

<div class="area">
  <div class="menu" role="toolbar">
    <a class="button" href="/">Menu</a>
    <button onclick={reset}>Reset</button>
    <button onclick={onClickDeck}>Deck</button>
  </div>
</div>

<DeckDialog bind:this={deckDialog} {onSelectCard} />
<CardRewardDialog bind:this={cardRewardDialog} />

<svelte:window {oncardreceived} />

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
