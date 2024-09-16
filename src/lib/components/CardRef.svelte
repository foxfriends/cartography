<script lang="ts">
  import { cards, type CardType } from "$lib/data/cards";
  import Shimmer from "./Shimmer.svelte";

  let { id }: { id: CardType } = $props();
  let card = $derived(cards[id]);
</script>

<Shimmer style="--shimmer-color: rgb(164 85 217)">
  {card.name}
</Shimmer>
