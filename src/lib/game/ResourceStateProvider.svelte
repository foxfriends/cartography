<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import { getGameState } from "./GameStateProvider.svelte";
  import { type ResourceType } from "$lib/data/resources";
  import type { CardId } from "$lib/engine/Card";
  import { type DeckCard, indexById as indexDeckById } from "$lib/engine/DeckCard";
  import { canProduce, isDependent, sourceIsProducing, type ProducingCard } from "$lib/engine/Card";
  import { coordinatesInRange, isInRange, type FieldCard } from "$lib/engine/FieldCard";
  import { cards, type Card } from "$lib/data/cards";

  const RESOURCE_STATE = Symbol("RESOURCE_STATE");

  type Input = {
    cardId: CardId;
    resource: ResourceType;
    quantity: number;
  };

  type Output = {
    resource: ResourceType;
    quantity: number;
    consumedBy: CardId[];
  };

  type Production = {
    inputs: Input[];
    outputs: Output[];
  };

  export type ResourceState = {
    readonly production: Record<CardId, Production>;
  };

  export type Legacy = {
    readonly produced: {
      cardId: CardId;
      resource: ResourceType;
      produced: number;
      consumed?: number;
    }[][][];
  };

  export function getResourceState(): Legacy {
    return getContext(RESOURCE_STATE);
  }
</script>

<script lang="ts">
  type Producer = { card: ProducingCard; field: FieldCard; deck: DeckCard };

  let { children }: { children: Snippet } = $props();
  const { deck, field, geography } = getGameState();

  let deckById = $derived(indexDeckById(deck));
  let cardsOnField = $derived(
    field
      .filter((fc) => !fc.loose)
      .map((fc) => ({ field: fc, deck: deckById.get(fc.id)! }))
      .map((fdc) => ({ ...fdc, card: cards[fdc.deck.type] as Card })),
  );
  let producers = $derived(cardsOnField.filter((card): card is Producer => canProduce(card.card)));

  let produced = $derived.by(() => {
    const produced: {
      cardId: CardId;
      resource: ResourceType;
      produced: number;
      consumed?: number;
    }[][][] = geography.terrain.map((row) => row.map(() => []));

    const remaining = new Map(
      producers.map((self) => {
        const nearby = producers
          .filter((other) => isInRange(self.field, other.field))
          .filter((other) => isDependent(self.card, other.card));
        return [self, new Set(nearby)];
      }),
    );

    const producing = Array.from(remaining)
      .filter(([, dependencies]) => dependencies.size === 0)
      .map(([card]) => card);

    nextCard: while (producing.length > 0) {
      const current = producing.shift()!;
      for (const [key, value] of remaining.entries()) {
        if (value.delete(current) && value.size === 0) producing.push(key);
      }

      switch (current.card.category) {
        case "production": {
          const inputs = current.card.inputs.map((input) => {
            const producedInRange = Array.from(coordinatesInRange(current.field))
              .flatMap(([x, y]) => produced[y][x])
              .filter((output) => input.resource === output.resource);

            let requirement = input.quantity;
            const consumeFrom = [];
            for (const output of producedInRange) {
              const outputLeft = output.produced - (output.consumed ?? 0);
              if (requirement <= outputLeft) {
                consumeFrom.push({ output, consume: requirement });
                requirement = 0;
                break;
              } else {
                consumeFrom.push({ output, consume: outputLeft });
                requirement -= outputLeft;
              }
            }
            return { input, requirement, consumeFrom };
          });
          if (!inputs.every((input) => input.requirement === 0)) {
            continue nextCard;
          }
          for (const input of inputs) {
            for (const { output, consume } of input.consumeFrom) {
              output.consumed = (output.consumed ?? 0) + consume;
            }
          }
          break;
        }
        case "source": {
          if (!sourceIsProducing({ card: current.card, field: current.field }, geography))
            continue nextCard;
          break;
        }
        default:
          current.card satisfies never;
          throw new Error("Unreachable");
      }
      for (const output of current.card.outputs) {
        produced[current.field.y][current.field.x].push({
          cardId: current.deck.id,
          produced: output.quantity,
          resource: output.resource,
        });
      }
    }
    return produced;
  });

  setContext(RESOURCE_STATE, {
    get produced() {
      return produced;
    },
  } satisfies Legacy);
</script>

{@render children()}
