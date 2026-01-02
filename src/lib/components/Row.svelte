<script lang="ts" generics="T">
  import type { Snippet } from "svelte";

  const { items, item }: { items: T[]; item: Snippet<[T]> } = $props();
</script>

<div class="row">
  {#each items as data (data)}
    {@render item(data)}
  {/each}
</div>

<style>
  @property --row-gap {
    syntax: "<length>";
    inherits: false;
    initial-value: 1rem;
  }

  .row {
    width: 100%;
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    gap: var(--row-gap, 1rem);
  }
</style>
