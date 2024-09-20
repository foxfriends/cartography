<script lang="ts" generics="T extends CardT = CardT">
  /* global T */
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  import type { Card as CardT } from "$lib/data/cards";
  import type { Snippet } from "svelte";
  import Card from "./Card.svelte";

  let { cards, card }: { cards: T[]; card?: Snippet<[T]> } = $props();
</script>

<div class="grid">
  {#each cards as data}
    {#if card}
      {@render card(data)}
    {:else}
      <Card card={data} />
    {/if}
  {/each}
</div>

<style>
  @property --card-grid-gap {
    syntax: "<length>";
    inherits: false;
    initial-value: 1rem;
  }

  .grid {
    width: 100%;
    display: grid;
    grid-auto-flow: row;
    grid-template-columns: repeat(auto-fill, minmax(18rem, 1fr));
    grid-auto-rows: auto;
    align-content: start;
    gap: var(--card-grid-gap, 1rem);
  }
</style>
