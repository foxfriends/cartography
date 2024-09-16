<script lang="ts">
  import type { Card } from "$lib/data/cards.ts";
  import { enter, opt } from "$lib/events";

  let { card, onSelect }: { card: Card; onSelect?: () => void } = $props();
</script>

<div
  class="card"
  class:selectable={onSelect}
  onclick={onSelect}
  onkeydown={opt(enter)(onSelect)}
  role="button"
  tabindex={0}
>
  <div class="title">{card.name} | {card.category}</div>
  <div class="image"></div>
  <div class="info">This is a card description.</div>
</div>

<style>
  .card {
    width: 100%;
    aspect-ratio: 2.5 / 3.5;
    box-shadow: 0 0 1rem rgb(0 0 0 / 0.125);
    padding: 0.5rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;

    transition:
      transform 200ms,
      box-shadow 200ms;

    &.selectable {
      cursor: pointer;

      &:hover,
      &:focus-visible {
        transform: scale(1.05);
        box-shadow: 0 0 2rem rgb(91 200 227 / 0.5);
        outline: 1px solid rgb(91 200 227);
      }
    }

    .title {
      padding: 0.125rem;
      border: 1px solid rgb(0 0 0 / 0.12);
    }

    .image {
      aspect-ratio: 1 / 1;
      width: 100%;
      background-color: rgb(0 0 0 / 0.1);
    }

    .info {
      border: 1px solid rgb(0 0 0 / 0.12);
      flex-grow: 1;
      padding: 0.125rem;
    }
  }
</style>
