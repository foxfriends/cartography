<script lang="ts">
  import type { CardId } from "$lib/engine/Card";
  import type { DeckCard } from "$lib/engine/DeckCard";
  import type { Field } from "$lib/engine/FieldCard";
  import CardTile from "./CardTile.svelte";

  const {
    field = $bindable(),
    deck,
    onMoveCard,
  }: {
    field: Field[number][];
    deck: DeckCard[];
    onMoveCard: (id: CardId, deltaClientX: number, deltaClientY: number) => void;
  } = $props();
</script>

{#each field as card (card.id)}
  {@const deckCard = deck.find((dc) => dc.id === card.id)}
  {#if deckCard}
    <CardTile
      id={card.id}
      x={card.x}
      y={card.y}
      type={deckCard.type}
      onMove={(x, y) => onMoveCard(card.id, x, y)}
      loose={card.loose}
    />
  {/if}
{/each}
