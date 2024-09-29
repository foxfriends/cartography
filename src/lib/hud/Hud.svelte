<script lang="ts">
  import { type DeckCard } from "$lib/engine/DeckCard";
  import { type ResourceType } from "$lib/data/resources";
  import { cards, type Card } from "$lib/data/cards";
  import { getAppState } from "$lib/game/AppStateProvider.svelte";
  import { getGameState } from "$lib/game/GameStateProvider.svelte";
  import { getResourceState } from "$lib/game/ResourceStateProvider.svelte";
  import { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
  import type { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
  import type { CardFocusEvent } from "$lib/events/CardFocusEvent";
  import ResourceRef from "$lib/components/ResourceRef.svelte";
  import CardFocusDialog from "./CardFocusDialog.svelte";
  import CardRewardDialog from "./CardRewardDialog.svelte";
  import DeckDialog from "./DeckDialog.svelte";
  import ProductionReportDialog from "./ProductionReportDialog.svelte";
  import ShopDialog from "./ShopDialog.svelte";

  const appState = getAppState();

  const gameState = getGameState();
  const { deck, field, money } = $derived(gameState);

  const resourceState = getResourceState();
  const { resourceProduction, income } = $derived(resourceState);

  let deckDialog: ReturnType<typeof DeckDialog> | undefined = $state();
  let shopDialog: ReturnType<typeof ShopDialog> | undefined = $state();
  let cardRewardDialog: ReturnType<typeof CardRewardDialog> | undefined = $state();
  let cardFocusDialog: ReturnType<typeof CardFocusDialog> | undefined = $state();
  let productionReportDialog: ReturnType<typeof ProductionReportDialog> | undefined = $state();

  const tradingCentre = $derived(deck.find((card) => card.type === "trading-centre"));
  const tradingCentreOnField = $derived(field.find((card) => card.id === tradingCentre?.id));
  const hasTrade = $derived(tradingCentreOnField && !tradingCentreOnField.loose);

  function onClickDeck() {
    deckDialog?.show();
  }

  function onClickShop() {
    shopDialog?.show();
  }

  function onClickFlow() {
    appState.mode = appState.mode === "flow" ? "place" : "flow";
  }

  function onClickProduction() {
    productionReportDialog?.show();
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

  function oncardsreceived(event: CardsReceivedEvent) {
    cardRewardDialog?.show(event.cards.map((card) => cards[card.type]));
  }

  function oncardfocus(event: CardFocusEvent) {
    const deckCard = deck.find((card) => card.id === event.cardId);
    if (!deckCard) return;
    const card = cards[deckCard.type];
    window.setTimeout(() => cardFocusDialog?.show(card), 0);
  }
</script>

<div class="area">
  <div class="status">
    <div class="title-area">
      <span class="title">Your Town</span>
      <span>${money}</span>
      <span>${income} / day</span>
    </div>
    <div class="resource-area">
      {#each Object.entries(resourceProduction) as [resource, { produced, consumed, demand }] (resource)}
        <span>
          <ResourceRef id={resource as ResourceType} />
          {#if demand}
            {produced}/{demand}
          {:else}
            {produced - consumed}
          {/if}
        </span>
      {/each}
    </div>
  </div>

  <div class="menu" role="toolbar">
    <a class="button" href="/">Menu</a>
    <button onclick={reset}>Reset</button>
    <button onclick={onClickFlow}>Flow</button>
    {#if hasTrade}
      <button onclick={onClickProduction}>Prod</button>
      <button onclick={onClickShop}>Shop</button>
    {/if}
    <button onclick={onClickDeck}>Deck</button>
  </div>
</div>

<ProductionReportDialog bind:this={productionReportDialog} />
<DeckDialog bind:this={deckDialog} {onSelectCard} />
<ShopDialog bind:this={shopDialog} />
<CardRewardDialog bind:this={cardRewardDialog} />
<CardFocusDialog bind:this={cardFocusDialog} />

<svelte:window {oncardsreceived} {oncardfocus} />

<style>
  .area {
    pointer-events: none;
    position: relative;
    width: 100%;
    height: 100%;
    display: grid;

    grid-template:
      "status status" auto
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

  .status {
    pointer-events: auto;
    grid-area: status;
    padding: 0.4rem;
    display: flex;
    flex-direction: row;
    gap: 1rem;
    justify-content: space-between;
    background-color: rgb(255 255 255 / 0.8);
    backdrop-filter: blur(1rem);
    border-bottom: 1px solid rgb(0 0 0 / 0.12);
    font-size: 0.8rem;
  }

  .title-area {
    display: flex;
    flex-direction: row;
    gap: 1rem;
  }

  .resource-area {
    display: flex;
    flex-direction: row;
    gap: 0.5rem;
  }

  .title {
    font-weight: 600;
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
    font-size: 1rem;
  }
</style>
