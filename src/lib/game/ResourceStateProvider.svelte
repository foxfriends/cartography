<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import { getGameState } from "./GameStateProvider.svelte";
  import { type ResourceType } from "$lib/data/resources";
  import type { CardId } from "$lib/engine/Card";
  import { type DeckCard, indexById as indexDeckById } from "$lib/engine/DeckCard";
  import { canProduce, isDependent, sourceIsProducing, type ProducingCard } from "$lib/engine/Card";
  import {
    coordinatesInRange,
    indexByPosition,
    isInRange,
    type FieldCard,
  } from "$lib/engine/FieldCard";
  import { cards, type Card } from "$lib/data/cards";
  import { add } from "$lib/algorithm/reducer";

  const RESOURCE_STATE = Symbol("RESOURCE_STATE");

  interface Input {
    cardId: CardId;
    resource: ResourceType;
    quantity: number;
  }

  interface Consumer {
    id: CardId;
    quantity: number;
  }

  interface Output {
    resource: ResourceType;
    quantity: number;
    consumedBy: Consumer[];
  }

  interface Production {
    inputs: Input[];
    outputs: Output[];
  }

  export interface ResourceState {
    readonly production: Record<CardId, Production>;
  }

  export function getResourceState(): ResourceState {
    return getContext(RESOURCE_STATE);
  }
</script>

<script lang="ts">
  interface Producer {
    card: ProducingCard;
    field: FieldCard;
    deck: DeckCard;
  }

  const { children }: { children: Snippet } = $props();
  const { deck, field, geography } = getGameState();

  const deckById = $derived(indexDeckById(deck));
  const cardsOnField = $derived(
    field
      .filter((fc) => !fc.loose)
      .map((fc) => ({ field: fc, deck: deckById.get(fc.id)! }))
      .map((fdc) => ({ ...fdc, card: cards[fdc.deck.type] as Card })),
  );
  const producers = $derived(
    cardsOnField.filter((card): card is Producer => canProduce(card.card)),
  );
  const cardLayout = $derived(indexByPosition(field));

  const production = $derived.by(() => {
    const production: Record<CardId, Production> = {};

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

      const inputs: Input[] = [];
      switch (current.card.category) {
        case "production": {
          const tentativeInputs = current.card.inputs.map((input) => {
            const cardsInRange = Array.from(coordinatesInRange(current.field))
              .map((pos) => cardLayout.get(...pos))
              .filter((card) => card !== undefined);

            let remaining = input.quantity;
            const consumeFrom = [];
            for (const producer of cardsInRange) {
              const producerOutput = production[producer.id]?.outputs;
              if (!producerOutput) continue;
              for (const output of producerOutput) {
                if (output.resource !== input.resource) continue;
                const outputLeft =
                  output.quantity -
                  output.consumedBy.map((consumer) => consumer.quantity).reduce(add, 0);
                if (remaining <= outputLeft) {
                  consumeFrom.push({ producer, output, quantity: remaining });
                  remaining = 0;
                  break;
                } else {
                  consumeFrom.push({ producer, output, quantity: outputLeft });
                  remaining -= outputLeft;
                }
              }
            }
            return { input, remaining, consumeFrom };
          });
          if (!tentativeInputs.every((input) => input.remaining === 0)) {
            continue nextCard;
          }
          for (const input of tentativeInputs) {
            for (const { producer, output, quantity } of input.consumeFrom) {
              output.consumedBy.push({ id: current.deck.id, quantity });
              inputs.push({ cardId: producer.id, resource: output.resource, quantity });
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
      production[current.deck.id] = {
        inputs,
        outputs: current.card.outputs.map((output) => ({ ...output, consumedBy: [] })),
      };
    }
    return production;
  });

  setContext(RESOURCE_STATE, {
    get production() {
      return production;
    },
  } satisfies ResourceState);
</script>

{@render children()}
