<script lang="ts" generics="T extends CardT = CardT">
  /* global T */
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  import type { Card as CardT } from "$lib/data/cards";
  import { apply, opt } from "$lib/events";
  import Card from "./Card.svelte";

  let { cards, onSelectCard }: { cards: T[]; onSelectCard?: (card: T) => void } = $props();
</script>

<div class="grid">
  {#each cards as card}
    <Card onSelect={opt(apply(card))(onSelectCard)} {card} />
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
