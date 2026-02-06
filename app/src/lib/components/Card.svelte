<script lang="ts">
  import type { Card } from "$lib/data/cards.ts";
  import { enter, opt } from "$lib/events";
  import ResourceRef from "./ResourceRef.svelte";
  import SpeciesRef from "./SpeciesRef.svelte";
  import TerrainRef from "./TerrainRef.svelte";

  const {
    card,
    onSelect,
    disabled = false,
  }: { card: Card; onSelect?: () => void; disabled?: boolean } = $props();
</script>

<div
  class="card"
  class:selectable={!disabled && onSelect}
  class:disabled
  onclick={disabled ? undefined : onSelect}
  onkeydown={disabled ? undefined : opt(enter)(onSelect)}
  role="button"
  tabindex={!disabled && onSelect ? 0 : undefined}
>
  <div class="title">{card.name} | {card.category}</div>
  <div class="image"></div>
  <div class="info">
    {#if card.category === "residential"}
      {#each card.population as pop (pop.species)}
        <p>
          Houses {pop.quantity}
          <SpeciesRef id={pop.species} plural={pop.quantity !== 1} />
        </p>
      {/each}
    {:else if card.category === "production"}
      {#each card.inputs as input (input.resource)}
        <p>
          Consumes {input.quantity}
          <ResourceRef id={input.resource} />
        </p>
      {/each}
      {#each card.outputs as output (output.resource)}
        <p>
          Produces {output.quantity}
          <ResourceRef id={output.resource} />
        </p>
      {/each}
    {:else if card.category === "source"}
      {#each card.source as source (source)}
        {#if source.type === "any"}
          <p>Produces anywhere</p>
        {/if}
        {#if source.type === "terrain"}
          <p>Produces on <TerrainRef id={source.terrain} /></p>
        {/if}
      {/each}
      {#each card.outputs as output (output.resource)}
        <p>
          Yields {output.quantity}
          <ResourceRef id={output.resource} />
        </p>
      {/each}
    {/if}
  </div>
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
      box-shadow 200ms,
      opacity 100ms;

    &.selectable {
      cursor: pointer;

      &:hover,
      &:focus-visible {
        transform: scale(1.05);
        box-shadow: 0 0 2rem rgb(91 200 227 / 0.5);
        outline: 1px solid rgb(91 200 227);
      }
    }

    &.disabled {
      opacity: 50%;

      &:hover {
        opacity: 100%;
      }
    }
  }

  .title {
    padding: 0.25rem;
    border: 1px solid rgb(0 0 0 / 0.12);
    white-space: nowrap;
  }

  .image {
    aspect-ratio: 1 / 1;
    width: 100%;
    background-color: rgb(0 0 0 / 0.1);
  }

  .info {
    border: 1px solid rgb(0 0 0 / 0.12);
    flex-grow: 1;
    padding: 0.25rem;
  }
</style>
