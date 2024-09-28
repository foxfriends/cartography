<script lang="ts">
  import { cards } from "$lib/data/cards";
  import type { Pack } from "$lib/game/GameStateProvider.svelte";
  import Card from "./Card.svelte";
  import CardBack from "./CardBack.svelte";
  import Row from "./Row.svelte";
  import PackRef from "./PackRef.svelte";
  import ShimmerBox from "./ShimmerBox.svelte";

  const { pack }: { pack: Pack } = $props();

  let hovering = $state(false);
</script>

<div
  class="pack"
  role="button"
  tabindex={0}
  onmouseover={() => (hovering = true)}
  onfocus={() => (hovering = true)}
  onmouseout={() => (hovering = false)}
  onblur={() => (hovering = false)}
>
  <div class="banner">
    <PackRef>{pack.name}</PackRef>
  </div>

  {#if pack.description}
    <div class="info">{pack.description}</div>
  {/if}

  {#if pack.originalPrice}
    <div class="price-tag replaced">
      <ShimmerBox
        style="--shimmer-color: oklch(from var(--color-money) l calc(c - 0.075) h); border-radius: 1rem; padding-inline: 1rem;"
      >
        <s class="price-label">${pack.originalPrice}</s>
      </ShimmerBox>
    </div>
  {/if}

  <div class="price-tag" class:replacement={!!pack.originalPrice}>
    <ShimmerBox
      style="--shimmer-color: var(--color-money); border-radius: 1rem; padding-inline: 1rem;"
    >
      <div class="price-label">
        ${pack.price}
      </div>
    </ShimmerBox>
  </div>
</div>

<dialog open={hovering} class="tooltip">
  <header>
    <PackRef>{pack.name}</PackRef>
  </header>
  <Row items={pack.contents}>
    {#snippet item(content)}
      <div class="card">
        {#if content.type === "card"}
          <Card card={cards[content.card]} disabled={content.missing} />
        {:else if content.type === "category"}
          <CardBack category={content.category} />
        {:else if content.type === "any"}
          <CardBack />
        {/if}
      </div>
    {/snippet}
  </Row>
</dialog>

<style>
  .pack {
    position: relative;
    width: 100%;
    aspect-ratio: 2.5 / 3.5;
    box-shadow: 0 0 1rem rgb(0 0 0 / 0.125);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    gap: 1rem;

    transition:
      transform 200ms,
      box-shadow 200ms,
      opacity 100ms;

    cursor: pointer;

    &:hover,
    &:focus-visible {
      transform: scale(1.05);
      box-shadow: 0 0 2rem rgb(91 200 227 / 0.5);
      outline: 1px solid rgb(91 200 227);
    }
  }

  .price-tag {
    position: absolute;
    top: 1rem;
    right: 1rem;
    display: flex;
    transform-origin: center;
  }

  .replacement {
    top: 2rem;
    right: 1rem;
    transform: translate(0) rotate(-10deg);
  }

  .price-label {
    font-size: 1.2rem;
    font-weight: 600;
  }

  s {
    text-decoration-color: rgb(230 25 66);
    text-decoration-thickness: 0.2rem;
  }

  .banner {
    padding: 0.5rem;
    border: 1px solid rgb(0 0 0 / 0.12);
    background-color: rgb(0 0 0 / 0.05);
  }

  .info {
    padding: 0.5rem;
    border: 1px solid rgb(0 0 0 / 0.12);
    background-color: rgb(0 0 0 / 0.05);
  }

  @property --tooltip-scale {
    syntax: "<number>";
    inherits: false;
    initial-value: 1;
  }

  dialog[open] {
    display: flex;
    opacity: 1;
    --tooltip-scale: 1;
  }

  dialog {
    position: absolute;
    pointer-events: none;
    left: 50%;
    top: 50%;
    border: none;
    box-shadow: 0 0 1rem rgb(0 0 0 / 0.5);
    opacity: 0;
    transform: translate(-50%, -50%) scale(var(--tooltip-scale));
    --tooltip-scale: 0.75;
    padding: 1rem;

    transition:
      opacity 100ms ease-out,
      transform 100ms ease-out,
      display 100ms ease-out allow-discrete,
      overlay 100ms ease-out allow-discrete;
  }

  @starting-style {
    dialog[open] {
      opacity: 0;
      --tooltip-scale: 0.97;
    }
  }

  .tooltip {
    flex-direction: column;
    gap: 1rem;
    width: max-content;
    max-width: 100%;
  }

  header {
    text-align: center;
    font-size: 2rem;
  }

  .card {
    width: 18rem;
  }
</style>
