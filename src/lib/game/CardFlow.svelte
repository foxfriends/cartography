<script lang="ts">
  import type { ResourceType } from "$lib/data/resources";
  import type { CardId } from "$lib/engine/Card";
  import type { Deck } from "$lib/engine/DeckCard";
  import type { Field, FieldCard } from "$lib/engine/FieldCard";
  import { generateFlowId, type Flow, type FlowId } from "$lib/engine/Flow";
  import { CreateFlowEvent } from "$lib/events/CreateFlowEvent";
  import { DeleteFlowEvent } from "$lib/events/DeleteFlowEvent";
  import type { StartFlowEvent } from "$lib/events/StartFlowEvent";
  import FlowLine from "./FlowLine.svelte";
  import ProductionOverlay from "./ProductionOverlay.svelte";

  const { flow, deck, field }: { flow: Flow[]; deck: Deck; field: Field } = $props();

  const validFlow = $derived(
    flow
      .map(({ source: sourceId, destination: destinationId, ...flow }) => {
        const source = field.find((card) => card.id === sourceId);
        const destination = field.find((card) => card.id === destinationId);
        if (!source || !destination) return undefined;
        return { ...flow, source, destination };
      })
      .filter((flow) => flow !== undefined)
      .toSorted((a, b) => a.priority - b.priority),
  );

  let clientHeight = $state(0);
  let clientWidth = $state(0);

  let draggingFlowSource:
    | {
        resource: ResourceType;
        sourceType: "input" | "output";
        anchor: HTMLDivElement;
        card: FieldCard;
      }
    | undefined = $state();
  let clientX = $state(0);
  let clientY = $state(0);

  const overlays: Record<CardId, ReturnType<typeof ProductionOverlay>> = $state({});

  function onStartFlow(event: StartFlowEvent & { currentTarget: HTMLDivElement }, card: FieldCard) {
    draggingFlowSource = {
      resource: event.resource,
      sourceType: event.sourceType,
      anchor: event.currentTarget,
      card,
    };
    clientX = event.clientX;
    clientY = event.clientY;
  }

  function onmousemove(event: MouseEvent) {
    if (!draggingFlowSource) return;
    clientX = event.clientX;
    clientY = event.clientY;
  }

  function onmouseup(event: MouseEvent) {
    if (event.button === 0 && draggingFlowSource) {
      const targetElement = document.elementFromPoint(clientX, clientY)?.closest("[data-cardid]");
      if (targetElement) {
        const destination = (targetElement as HTMLElement).dataset.cardid as CardId;
        window.dispatchEvent(
          new CreateFlowEvent({
            id: generateFlowId(),
            priority: 0,
            source:
              draggingFlowSource.sourceType === "output" ? draggingFlowSource.card.id : destination,
            destination:
              draggingFlowSource.sourceType === "output" ? destination : draggingFlowSource.card.id,
            resource: draggingFlowSource.resource,
          }),
        );
      }

      clientX = 0;
      clientY = 0;
      draggingFlowSource = undefined;
    }
  }

  function deleteFlow(id: FlowId) {
    window.dispatchEvent(new DeleteFlowEvent(id));
  }
</script>

<svelte:window {onmousemove} {onmouseup} />

{#each field as card (card.id)}
  {@const deckCard = deck.find((dc) => dc.id === card.id)!}
  <ProductionOverlay
    id={card.id}
    type={deckCard.type}
    x={card.x}
    y={card.y}
    onStartFlow={(event) => onStartFlow(event, card)}
    bind:this={overlays[card.id]}
  />
{/each}

<div class="full" bind:clientWidth bind:clientHeight>
  <svg viewBox="0 0 {clientWidth} {clientHeight}">
    {#each validFlow as flow (flow.id)}
      {@const start = overlays[flow.source.id]?.findOutput(flow.resource)?.getBoundingClientRect()}
      {@const end = overlays[flow.destination.id]
        ?.findInput(flow.resource)
        ?.getBoundingClientRect()}

      {#if start && end}
        <FlowLine
          x1={start.x + start.width / 2}
          y1={start.y + start.height / 2}
          x2={end.x + end.width / 2}
          y2={end.y + end.height / 2}
          onclick={() => deleteFlow(flow.id)}
        />
      {/if}
    {/each}

    {#if draggingFlowSource}
      {@const bbox = draggingFlowSource.anchor.getBoundingClientRect()}
      {@const x = bbox.x + bbox.width / 2}
      {@const y = bbox.y + bbox.height / 2}
      <FlowLine x1={x} y1={y} x2={clientX} y2={clientY} />
    {/if}
  </svg>
</div>

<style>
  .full {
    position: absolute;
    inset: 0;
    pointer-events: none;
  }
</style>
