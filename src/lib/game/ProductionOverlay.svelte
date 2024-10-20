<script lang="ts">
  import type { EventHandler } from "svelte/elements";
  import ResourceRef from "$lib/components/ResourceRef.svelte";
  import { cards, type CardType } from "$lib/data/cards";
  import { lmb, replace } from "$lib/events";
  import { StartFlowEvent } from "$lib/events/StartFlowEvent";
  import type { ResourceType } from "$lib/data/resources";
  import type { CardId } from "$lib/engine/Card";

  const {
    id,
    x,
    y,
    type: cardType,
    onStartFlow,
  }: {
    id: CardId;
    x: number;
    y: number;
    type: CardType;
    onStartFlow?: EventHandler<StartFlowEvent, HTMLDivElement> | null | undefined;
  } = $props();

  const cardSpec = $derived(cards[cardType]);

  const inputs: Partial<Record<ResourceType, HTMLDivElement>> = $state({});
  const outputs: Partial<Record<ResourceType, HTMLDivElement>> = $state({});

  export function findInput(resource: ResourceType): HTMLDivElement | undefined {
    return inputs[resource];
  }

  export function findOutput(resource: ResourceType): HTMLDivElement | undefined {
    return outputs[resource];
  }
</script>

<div class="gridspace" style="--grid-x: {x}; --grid-y: {y}" data-cardid={id}>
  {#if "inputs" in cardSpec}
    <div class="pips">
      {#each cardSpec.inputs as input (input.resource)}
        <div class="piprow">
          <div
            bind:this={inputs[input.resource]}
            class="pip input"
            role="presentation"
            onmousedown={lmb(
              replace(
                (event) =>
                  new StartFlowEvent({
                    resource: input.resource,
                    sourceType: "input",
                    clientX: event.clientX,
                    clientY: event.clientY,
                  }),
              ),
            )}
            onstartflow={onStartFlow}
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
            bind:this={outputs[output.resource]}
            class="pip output"
            role="presentation"
            onmousedown={lmb(
              replace(
                (event) =>
                  new StartFlowEvent({
                    resource: output.resource,
                    sourceType: "output",
                    clientX: event.clientX,
                    clientY: event.clientY,
                  }),
              ),
            )}
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
    width: var(--tile-width);
    height: var(--tile-height);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transform: translate(
      calc(var(--grid-x) * var(--tile-width) - var(--offset-x)),
      calc(var(--grid-y) * var(--tile-height) - var(--offset-y))
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
    display: flex;
    align-items: center;
    justify-content: center;
    width: 1rem;
    height: 1rem;
    pointer-events: all;
    cursor: pointer;

    &::after {
      content: "";
      width: 0.5rem;
      height: 0.5rem;
      border-radius: 100%;
    }

    &.output::after {
      --pulse-color: var(--color-output);
      background-color: var(--color-output);
      animation: pulse 1s ease-out infinite;
    }

    &.input::after {
      --pulse-color: var(--color-input);
      background-color: var(--color-input);
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
