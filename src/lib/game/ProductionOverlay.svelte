<script lang="ts">
  import type { EventHandler } from "svelte/elements";
  import ResourceRef from "$lib/components/ResourceRef.svelte";
  import { cards, type CardType } from "$lib/data/cards";
  import { replace } from "$lib/events";
  import { StartFlowEvent } from "$lib/events/StartFlowEvent";

  const {
    x,
    y,
    type: cardType,
    onStartFlow,
  }: {
    x: number;
    y: number;
    type: CardType;
    onStartFlow?: EventHandler<StartFlowEvent, HTMLDivElement> | null | undefined;
  } = $props();

  const cardSpec = $derived(cards[cardType]);
</script>

<div class="gridspace" style="--grid-x: {x}; --grid-y: {y}">
  {#if "inputs" in cardSpec}
    <div class="pips">
      {#each cardSpec.inputs as input (input.resource)}
        <div class="piprow">
          <div
            class="pip input"
            role="presentation"
            onmousedown={replace(() => new StartFlowEvent(input.resource, "input"))}
          ></div>
          <span>{input.quantity} &rarr; <ResourceRef id={input.resource} /></span>
        </div>
      {/each}
    </div>
  {/if}
  {#if "outputs" in cardSpec}
    <div class="pips">
      {#each cardSpec.outputs as output (output.resource)}
        <div class="piprow">
          <span><ResourceRef id={output.resource} /> &rarr; {output.quantity}</span>
          <div
            class="pip output"
            role="presentation"
            onmousedown={replace(() => new StartFlowEvent(output.resource, "output"))}
            onstartflow={onStartFlow}
          ></div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .gridspace {
    position: absolute;
    top: 0;
    left: 0;
    width: var(--card-size);
    height: var(--card-size);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transform: translate(
      calc(var(--grid-x) * var(--card-size) - var(--offset-x)),
      calc(var(--grid-y) * var(--card-size) - var(--offset-y))
    );
  }

  .pips {
    display: flex;
    flex-direction: column;
  }

  .piprow {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    padding-inline: 0.25rem;
  }

  .pip {
    width: 0.5rem;
    height: 0.5rem;
    border-radius: 100%;
    cursor: pointer;

    &.output {
      --pulse-color: var(--color-terrain);
      background-color: var(--color-terrain);
      animation: pulse 1s ease-out infinite;
    }

    &.input {
      --pulse-color: var(--color-resource);
      background-color: var(--color-resource);
      animation: pulse 1s infinite ease-out reverse;
    }
  }

  @keyframes pulse {
    from {
      box-shadow: 0 0 0 0 oklch(from var(--pulse-color) l c h / 0.8);
    }
    to {
      box-shadow: 0 0 0 0.25rem oklch(from var(--pulse-color) l c h / 0);
    }
  }
</style>
