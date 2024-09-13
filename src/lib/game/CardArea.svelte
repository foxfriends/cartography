<script lang="ts">
  import Card from "./Card.svelte";

  type PlacedCard = { id: string; x: number; y: number };

  let {
    cards,
    hand,
    onMoveCard,
  }: {
    cards: PlacedCard[];
    hand: { id: string; type: string }[];
    onMoveCard: (id: string, x: number, y: number) => void;
  } = $props();
</script>

{#each cards as card (card.id)}
  {@const handcard = hand.find((hc) => hc.id === card.id)}
  {#if handcard}
    <Card x={card.x} y={card.y} type={handcard.type} onMove={(x, y) => onMoveCard(card.id, x, y)} />
  {/if}
{/each}
