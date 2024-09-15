<script lang="ts">
  import type { Field } from "$lib/types";
  import Card from "./Card.svelte";

  let {
    field = $bindable(),
    deck,
    onMoveCard,
  }: {
    field: Field[number][];
    deck: { id: string; type: string }[];
    onMoveCard: (id: string, deltaClientX: number, deltaClientY: number) => void;
  } = $props();
</script>

{#each field as card (card)}
  {@const handcard = deck.find((hc) => hc.id === card.id)}
  {#if handcard}
    <Card
      x={card.x}
      y={card.y}
      type={handcard.type}
      onMove={(x, y) => onMoveCard(card.id, x, y)}
      loose={card.loose}
    />
  {/if}
{/each}
