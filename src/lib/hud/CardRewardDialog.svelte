<script lang="ts">
  import CardGrid from "$lib/components/CardGrid.svelte";
  import ShimmerModal from "$lib/components/ShimmerModal.svelte";
  import type { Card } from "$lib/data/cards";

  let dialog: ShimmerModal | undefined = $state();
  let cards: Card[] = $state([]);

  export function show(cardsToShow: Card[]) {
    cards = cardsToShow;
    dialog?.show();
  }
</script>

<ShimmerModal style="--shimmer-color: rgb(164 85 217)" bind:this={dialog}>
  <article>
    <header><h1>Card Received!</h1></header>
    <CardGrid {cards} />
    <button onclick={() => dialog?.close()}>Sweet!</button>
  </article>
</ShimmerModal>

<style>
  article {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
    padding: 1rem;
  }

  header {
    text-align: center;
  }
</style>
