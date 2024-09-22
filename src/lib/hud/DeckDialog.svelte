<script lang="ts">
  import CardGrid from "$lib/components/CardGrid.svelte";
  import { cards, type Card as CardT } from "$lib/data/cards";
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import Modal from "$lib/components/Modal.svelte";
  import { DeckOpenedEvent } from "$lib/events/DeckOpenedEvent";
  import Card from "$lib/components/Card.svelte";
  import { apply } from "$lib/events";
  import type { DeckCard } from "$lib/engine/DeckCard";

  let { onSelectCard }: { onSelectCard: (card: CardT & { deckCard: DeckCard }) => void } = $props();

  const { deck, field } = getGameState();
  let deckCards = $derived(
    deck.map((deckCard) => ({
      ...cards[deckCard.type],
      deckCard,
      isFielded: field.some((f) => f.id === deckCard.id),
    })),
  );

  let dialog: Modal | undefined = $state();

  export function show() {
    dialog?.show();
    window.dispatchEvent(new DeckOpenedEvent());
  }

  export function close() {
    dialog?.close();
  }
</script>

<Modal bind:this={dialog}>
  <article>
    <header>
      <h1>Deck</h1>
      <button class="close" onclick={() => dialog!.close()}>&times;</button>
    </header>
    <div class="content">
      <CardGrid cards={deckCards}>
        {#snippet card(card)}
          <Card {card} onSelect={apply(card)(onSelectCard)} disabled={card.isFielded} />
        {/snippet}
      </CardGrid>
    </div>
  </article>
</Modal>

<style>
  .content {
    padding: 2rem;
    --card-grid-gap: 2rem;
  }

  header {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgb(0 0 0 / 0.12);
    padding: 2rem;
  }

  .close {
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid rgb(0 0 0 / 0.12);
    background: none;
    width: 2rem;
    aspect-ratio: 1 / 1;
    font-size: 1rem;
  }
</style>
