<script lang="ts" generics="T extends CardT = CardT">
  import type { Card as CardT } from "$lib/data/cards";
  import type { Snippet } from "svelte";
  import Card from "./Card.svelte";
  import Grid from "./Grid.svelte";

  const { cards, card }: { cards: T[]; card?: Snippet<[T]> } = $props();
</script>

<Grid items={cards}>
  {#snippet item(data)}
    {#if card}
      {@render card(data)}
    {:else}
      <Card card={data} />
    {/if}
  {/snippet}
</Grid>
