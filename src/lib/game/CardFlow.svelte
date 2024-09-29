<script lang="ts">
  import type { CardId } from "$lib/engine/Card";
  import type { Deck } from "$lib/engine/DeckCard";
  import type { Field } from "$lib/engine/FieldCard";
  import type { Flow } from "$lib/engine/Flow";
  import type { StartFlowEvent } from "$lib/events/StartFlowEvent";
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

  function onStartFlow(
    _event: StartFlowEvent & { currentTarget: HTMLDivElement },
    _cardId: CardId,
  ) {}
</script>

{#each field as card (card.id)}
  {@const deckCard = deck.find((dc) => dc.id === card.id)!}
  <ProductionOverlay
    type={deckCard.type}
    x={card.x}
    y={card.y}
    onStartFlow={(event) => onStartFlow(event, card.id)}
  />
{/each}

{#each validFlow as flow (flow.id)}
  <div></div>
{/each}
