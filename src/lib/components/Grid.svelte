<script lang="ts" generics="T">
  /* global T */
  import type { Snippet } from "svelte";

  const { items, item }: { items: T[]; item: Snippet<[T]> } = $props();
</script>

<div class="grid">
  {#each items as data}
    {@render item(data)}
  {/each}
</div>

<style>
  @property --grid-gap {
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
    gap: var(--grid-gap, 1rem);
  }
</style>
