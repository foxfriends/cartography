<script lang="ts" module>
  import { getContext, setContext, type Snippet } from "svelte";
  import { SvelteMap } from "svelte/reactivity";
  import { resources, type ResourceType } from "$lib/data/resources";
  import { cards, type Population } from "$lib/data/cards";
  import { species, type SpeciesType } from "$lib/data/species";
  import { indexById as indexDeckById } from "$lib/engine/DeckCard";
  import { indexById as indexFieldById, indexByPosition } from "$lib/engine/FieldCard";
  import { indexByDestination } from "$lib/engine/Flow";
  import { canProduce, sourceIsProducing, type CardId } from "$lib/engine/Card";
  import { add } from "$lib/algorithm/reducer";
  import { getGameState } from "./GameStateProvider.svelte";

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

  interface SpeciesPopulation {
    quantity: number;
  }

  export interface ResourceState {
    readonly population: Partial<Record<SpeciesType, SpeciesPopulation>>;
    readonly cardProduction: Record<CardId, CardProduction>;
    readonly resourceProduction: Partial<Record<ResourceType, ResourceProduction>>;
    readonly income: number;
  }

  export function getResourceState(): ResourceState {
    return getContext(RESOURCE_STATE);
  }
</script>

<script lang="ts">
  const { children }: { children: Snippet } = $props();
  const gameState = getGameState();
  const { deck, field, flow, geography } = $derived(gameState);

  const deckById = $derived(indexDeckById(deck));
  const fieldById = $derived(indexFieldById(field));
  const _cardLayout = $derived(indexByPosition(field));
  const flowGraph = $derived(indexByDestination(flow));
  const cardsOnField = $derived(field.filter((fc) => !fc.loose));

  const population = $derived(
    cardsOnField
      .map((field) => deckById.get(field.id)!)
      .map((deck) => cards[deck.type])
      .filter((card) => card.category === "residential")
      .flatMap((card) => card.population as Population[])
      .reduce<Partial<Record<SpeciesType, SpeciesPopulation>>>((population, residence) => {
        population[residence.species] ??= { quantity: 0 };
        population[residence.species]!.quantity += residence.quantity;
        return population;
      }, {}),
  );

  const cardProduction = $derived.by(() => {
    const cardProduction: Record<CardId, CardProduction> = {};
    const remaining = new SvelteMap(
      Array.from(flowGraph.entries())
        .filter(([, inputs]) => inputs.length)
        .map(([id, inputs]) => [id, [...inputs]]),
    );
    const producing = cardsOnField
      .filter((field) => canProduce(cards[deckById.get(field.id)!.type]))
      .filter((field) => !flowGraph.get(field.id)?.length)
      .map((field) => field.id);

    nextCard: while (producing.length) {
      const currentId = producing.shift()!;
      const currentField = fieldById.get(currentId)!;
      const currentDeck = deckById.get(currentId)!;
      const currentCard = cards[currentDeck.type];

      for (const [id, flows] of remaining.entries()) {
        const left = flows.filter((flow) => flow.source === currentId);
        if (left.length) {
          remaining.set(id, left);
        } else {
          remaining.delete(id);
          producing.push(id);
        }
      }

      const inputs: Input[] = [];
      switch (currentCard.category) {
        case "production": {
          const sources = flowGraph.get(currentId);
          const tentativeInputs = currentCard.inputs.map((input) => {
            const consumeFrom = [];
            let remaining: number = input.quantity;
            if (sources) {
              for (const flow of sources) {
                const producerOutput = cardProduction[flow.source]?.outputs;
                if (!producerOutput) continue;

                for (const output of producerOutput) {
                  if (output.resource !== input.resource) continue;

                  const outputLeft =
                    output.quantity -
                    output.consumedBy.map((consumer) => consumer.quantity).reduce(add, 0);
                  if (remaining <= outputLeft) {
                    consumeFrom.push({ flow, output, quantity: remaining });
                    remaining = 0;
                    break;
                  } else {
                    consumeFrom.push({ flow, output, quantity: outputLeft });
                    remaining -= outputLeft;
                  }
                }
              }
            }
            return { input, remaining, consumeFrom };
          });
          if (!tentativeInputs.every((input) => input.remaining === 0)) continue nextCard;

          for (const input of tentativeInputs) {
            for (const { flow, output, quantity } of input.consumeFrom) {
              output.consumedBy.push({ id: currentId, quantity });
              inputs.push({ cardId: flow.source, resource: output.resource, quantity });
            }
          }
          break;
        }
        case "source": {
          if (!sourceIsProducing({ card: currentCard, field: currentField }, geography)) {
            continue nextCard;
          }
          break;
        }
        case "residential":
        case "trade":
          continue nextCard;
        default:
          currentCard satisfies never;
          throw new Error("Unreachable");
      }
      cardProduction[currentId] = {
        inputs,
        outputs: currentCard.outputs.map((output) => ({ ...output, consumedBy: [] })),
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
