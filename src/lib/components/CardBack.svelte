<script lang="ts">
  import type { CardCategory } from "$lib/data/cards.ts";

  const { category }: { category?: CardCategory } = $props();
</script>

<div class="card-back">
  {#if category}
    <div class="category">{category}</div>
  {/if}
</div>

<style>
  .card-back {
    width: 100%;
    aspect-ratio: 2.5 / 3.5;
    box-shadow: 0 0 1rem rgb(0 0 0 / 0.125);
  }

  .category {
    text-transform: capitalize;
  }
</style>
