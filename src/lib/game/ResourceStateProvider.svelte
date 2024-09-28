<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import { getGameState } from "./GameStateProvider.svelte";
  import { resources, type ResourceType } from "$lib/data/resources";
  import type { CardId } from "$lib/engine/Card";
  import { type DeckCard, indexById as indexDeckById } from "$lib/engine/DeckCard";
  import { canProduce, isDependent, sourceIsProducing, type ProducingCard } from "$lib/engine/Card";
  import {
    coordinatesInRange,
    indexByPosition,
    isInRange,
    type FieldCard,
  } from "$lib/engine/FieldCard";
  import { cards, type Card, type ResidentialCard } from "$lib/data/cards";
  import { add } from "$lib/algorithm/reducer";
  import { species, type SpeciesType } from "$lib/data/species";

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

  interface CardProduction {
    inputs: Input[];
    outputs: Output[];
  }

  export interface ResourceProduction {
    produced: number;
    consumed: number;
    demand: number;
  }

  interface Population {
    quantity: number;
  }

  export interface ResourceState {
    readonly population: Partial<Record<SpeciesType, Population>>;
    readonly cardProduction: Record<CardId, CardProduction>;
    readonly resourceProduction: Partial<Record<ResourceType, ResourceProduction>>;
    readonly income: number;
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

  interface Residential {
    card: ResidentialCard;
    field: FieldCard;
    deck: DeckCard;
  }

  const { children }: { children: Snippet } = $props();
  const gameState = getGameState();
  const { deck, field, geography } = $derived(gameState);

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

  const population = $derived(
    cardsOnField
      .filter((card): card is Residential => card.card.category === "residential")
      .flatMap((card) => card.card.population)
      .reduce<Partial<Record<SpeciesType, Population>>>((population, residence) => {
        population[residence.species] ??= { quantity: 0 };
        population[residence.species]!.quantity += residence.quantity;
        return population;
      }, {}),
  );

  const cardProduction = $derived.by(() => {
    const cardProduction: Record<CardId, CardProduction> = {};

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
              const producerOutput = cardProduction[producer.id]?.outputs;
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
      cardProduction[current.deck.id] = {
        inputs,
        outputs: current.card.outputs.map((output) => ({ ...output, consumedBy: [] })),
      };
    }

    return cardProduction;
  });

  const resourceProduction = $derived.by(() => {
    const resourceProduction = Object.values(cardProduction)
      .flatMap((card) => card.outputs)
      .reduce<Partial<Record<ResourceType, ResourceProduction>>>((resourceProduction, output) => {
        resourceProduction[output.resource] ??= { produced: 0, consumed: 0, demand: 0 };
        resourceProduction[output.resource]!.produced += output.quantity;
        for (const { quantity } of output.consumedBy) {
          resourceProduction[output.resource]!.consumed += quantity;
        }
        return resourceProduction;
      }, {});

    for (const [specie, { quantity }] of Object.entries(population)) {
      for (const need of species[specie as SpeciesType].needs) {
        if (need.type !== "resource") continue;
        resourceProduction[need.resource] ??= { produced: 0, consumed: 0, demand: 0 };
        resourceProduction[need.resource]!.demand += quantity * need.quantity;
      }
    }

    return resourceProduction;
  });

  const income = $derived(
    Object.entries(resourceProduction)
      .map(([resource, { produced, consumed, demand }]) => {
        const value = resources[resource as ResourceType].value;
        return (
          value * Math.max(0, produced - consumed - demand) +
          value * 5 * Math.min(demand, Math.max(0, produced - consumed))
        );
      })
      .reduce(add, 0),
  );

  setContext(RESOURCE_STATE, {
    get population() {
      return population;
    },
    get cardProduction() {
      return cardProduction;
    },
    get resourceProduction() {
      return resourceProduction;
    },
    get income() {
      return income;
    },
  } satisfies ResourceState);
</script>

{@render children()}
