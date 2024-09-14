<script lang="ts">
  import Card from "./Card.svelte";

  type PlacedCard = { id: string; x: number; y: number };

  let {
    field = $bindable(),
    deck,
    onMoveCard,
  }: {
    field: PlacedCard[];
    deck: { id: string; type: string }[];
    onMoveCard: (id: string, deltaClientX: number, deltaClientY: number) => void;
  } = $props();
</script>

{#each field as card (card.id)}
  {@const handcard = deck.find((hc) => hc.id === card.id)}
  {#if handcard}
    <Card x={card.x} y={card.y} type={handcard.type} onMove={(x, y) => onMoveCard(card.id, x, y)} />
  {/if}
{/each}
