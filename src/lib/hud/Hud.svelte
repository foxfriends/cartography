<script lang="ts">
  import { cards, type Card } from "$lib/data/cards";
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
  import type { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
  import CardRewardDialog from "./CardRewardDialog.svelte";
  import DeckDialog from "./DeckDialog.svelte";
  import { resources, type ResourceType } from "$lib/data/resources";
  import CardFocusDialog from "./CardFocusDialog.svelte";
  import type { CardFocusEvent } from "$lib/events/CardFocusEvent";
  import ResourceRef from "$lib/components/ResourceRef.svelte";
  import { type DeckCard } from "$lib/engine/DeckCard";
  import { getResourceState } from "$lib/game/ResourceStateProvider.svelte";

  const { deck, field, money } = getGameState();

  let deckDialog: DeckDialog | undefined = $state();
  let cardRewardDialog: CardRewardDialog | undefined = $state();
  let cardFocusDialog: CardFocusDialog | undefined = $state();

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

  function oncardsreceived(event: CardsReceivedEvent) {
    cardRewardDialog?.show(event.cards.map((card) => cards[card.type]));
  }

  function oncardfocus(event: CardFocusEvent) {
    const deckCard = deck.find((card) => card.id === event.cardId);
    if (!deckCard) return;
    const card = cards[deckCard.type];
    window.setTimeout(() => cardFocusDialog?.show(card), 0);
  }

  const { produced } = getResourceState();

  let summary = $derived(
    produced
      .flat()
      .flat()
      .reduce<Map<ResourceType, { produced: number; consumed: number }>>((summary, production) => {
        const total = summary.get(production.resource) ?? { produced: 0, consumed: 0 };
        total.produced += production.produced;
        if (production.consumed) total.consumed += production.consumed;
        return summary.set(production.resource, total);
      }, new Map()),
  );

  let income = $derived(
    Array.from(summary)
      .map(
        ([resource, { produced, consumed }]) => resources[resource].value * (produced - consumed),
      )
      .reduce((a, b) => a + b, 0),
  );
</script>

<div class="area">
  <div class="status">
    <div class="title-area">
      <span class="title">Your Town</span>
      <span>${money}</span>
      <span>${income} / day</span>
    </div>
    <div class="resource-area">
      {#each summary.entries() as [resource, { produced, consumed }] (resource)}
        <span>
          <ResourceRef id={resource} />
          {produced}/{consumed}
        </span>
      {/each}
    </div>
  </div>

  <div class="menu" role="toolbar">
    <a class="button" href="/">Menu</a>
    <button onclick={reset}>Reset</button>
    <button onclick={onClickDeck}>Deck</button>
  </div>
</div>

<DeckDialog bind:this={deckDialog} {onSelectCard} />
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
