<script lang="ts">
  import Card from "$lib/components/Card.svelte";
  import Row from "$lib/components/Row.svelte";
  import ShimmerModal from "$lib/components/ShimmerModal.svelte";
  import type { Card as CardT } from "$lib/data/cards";

  let dialog: ShimmerModal | undefined = $state();
  let cards: CardT[] = $state([]);

  export function show(cardsToShow: CardT[]) {
    cards = cardsToShow;
    dialog?.show();
  }
</script>

<ShimmerModal style="--shimmer-color: rgb(164 85 217)" bind:this={dialog}>
  <article>
    <header><h1>Card Received!</h1></header>
    <Row items={cards}>
      {#snippet item(card)}
        <div class="card">
          <Card {card} />
        </div>
      {/snippet}
    </Row>
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

  .card {
    width: 18rem;
  }
</style>
