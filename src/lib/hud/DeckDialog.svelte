<script lang="ts">
  import CardGrid from "$lib/components/CardGrid.svelte";
  import { cards, type Card } from "$lib/data/cards";
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import type { DeckCard } from "$lib/types";
  import Modal from "$lib/components/Modal.svelte";
  import { DeckOpenedEvent } from "$lib/events/DeckOpenedEvent";

  let { onSelectCard }: { onSelectCard: (card: Card & { deckCard: DeckCard }) => void } = $props();

  let { deck, field } = getGameState();
  let deckCards = $derived(
    deck
      .filter(({ id }) => !field.some((f) => f.id === id))
      .map((deckCard) => ({ ...cards[deckCard.type], deckCard })),
  );

  let dialog: Modal | undefined = $state();

  export function show() {
    dialog!.show();
    window.dispatchEvent(new DeckOpenedEvent());
  }
</script>

<Modal bind:this={dialog}>
  <article>
    <header>
      <h1>Deck</h1>
      <button class="close" onclick={() => dialog!.close()}>&times;</button>
    </header>
    <div class="content">
      <CardGrid cards={deckCards} {onSelectCard} />
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
    border: 1px solid rgb(0 0 0 / 0.12);
    background: none;
    width: 2rem;
    height: 2rem;
  }
</style>
