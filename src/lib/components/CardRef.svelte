<script lang="ts">
  import { cards, type CardType } from "$lib/data/cards";
  import Shimmer from "./Shimmer.svelte";

  const { id }: { id: CardType } = $props();
  const card = $derived(cards[id]);
</script>

<Shimmer style="--shimmer-color: var(--color-card)">
  {card.name}
</Shimmer>
