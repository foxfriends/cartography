<script lang="ts">
  import { cards, type Card } from "$lib/data/cards";
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
  import type { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
  import type { DeckCard } from "$lib/types";
  import CardRewardDialog from "./CardRewardDialog.svelte";
  import DeckDialog from "./DeckDialog.svelte";
  import { resources, type ResourceType } from "$lib/data/resources";
  import CardFocusDialog from "./CardFocusDialog.svelte";
  import type { CardFocusEvent } from "$lib/events/CardFocusEvent";
  import { nearestEdgeDistance } from "$lib/algorithm/nearestEdge";
  import { rangeInclusive } from "$lib/algorithm/range";
  import ResourceRef from "$lib/components/ResourceRef.svelte";

  let { deck, field, geography } = getGameState();

  let deckDialog: DeckDialog | undefined = $state();
  let cardRewardDialog: CardRewardDialog | undefined = $state();
  let cardFocusDialog: CardFocusDialog | undefined = $state();

  function onClickDeck() {
    deckDialog?.show();
  }

  function onSelectCard(card: Card & { deckCard: DeckCard }) {
    window.dispatchEvent(new CardFieldedEvent(card.deckCard));
    field.push({ id: card.deckCard.id, x: 0, y: 0, loose: true });
    deckDialog?.close();
  }

  function reset() {
    window.localStorage.clear();
    window.location.reload();
  }

  function oncardsreceived(event: CardsReceivedEvent) {
    cardRewardDialog?.show(event.cards.map((card) => cards[card.type]));
  }

  function oncardfocus(event: CardFocusEvent) {
    const deckCard = deck.find((card) => card.id === event.cardId);
    if (!deckCard) return;
    const card = cards[deckCard.type];
    window.setTimeout(() => cardFocusDialog?.show(card), 0);
  }

  function isDependent(consumer: Card, producer: Card) {
    if (consumer.category !== "production") return false;
    if (producer.category !== "production" && producer.category !== "source") return false;
    return consumer.inputs.some((input) =>
      producer.outputs.some((output) => output.resource === input.resource),
    );
  }

  const PRODUCTION_ACCESS_RANGE = 2;

  let cardsOnField = $derived(
    field
      .filter((fc) => !fc.loose)
      .map((fc) => ({ field: fc, deck: deck.find((dc) => dc.id === fc.id)! }))
      .map((fdc) => ({ ...fdc, card: cards[fdc.deck.type] })),
  );

  let produced = $derived.by(() => {
    const produced: {
      cardId: string;
      resource: ResourceType;
      quantity: number;
      consumed?: number;
    }[][][] = geography.terrain.map((row) => row.map(() => []));

    const producers = cardsOnField.filter(
      (card) => card.card.category === "source" || card.card.category === "production",
    );

    const remaining = new Map(
      producers.map((self) => {
        const nearby = producers
          .filter(
            (other) => nearestEdgeDistance(self.field, other.field) <= PRODUCTION_ACCESS_RANGE,
          )
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
            const producedInRange = Array.from(
              rangeInclusive(
                current.field.y - PRODUCTION_ACCESS_RANGE,
                current.field.y + PRODUCTION_ACCESS_RANGE,
              ),
              (y) =>
                Array.from(
                  rangeInclusive(
                    current.field.x - PRODUCTION_ACCESS_RANGE,
                    current.field.x + PRODUCTION_ACCESS_RANGE,
                  ),
                  (x) => [x, y],
                ),
            )
              .flat()
              .flatMap(([x, y]) => produced[y][x])
              .filter((output) => input.resource === output.resource);

            let requirement: number = input.quantity;
            const consumeFrom = [];
            for (const output of producedInRange) {
              const outputLeft = output.quantity - (output.consumed ?? 0);
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
          const isValidSource = current.card.source.some((source) => {
            switch (source.type) {
              case "terrain":
                if (geography.terrain[current.field.y]?.[current.field.x].type === source.terrain) {
                  return true;
                }
                break;
              case "any":
                return true;
            }
          });
          if (!isValidSource) continue nextCard;
          break;
        }
        case "residential":
        case "trade":
          continue nextCard;
        default:
          current.card satisfies never;
          throw new Error("Unreachable");
      }
      for (const output of current.card.outputs) {
        produced[current.field.y][current.field.x].push({
          cardId: current.deck.id,
          quantity: output.quantity,
          resource: output.resource,
        });
      }
    }
    return produced;
  });

  let summary = $derived(
    produced
      .flat()
      .flat()
      .reduce<Map<ResourceType, { produced: number; consumed: number }>>((summary, production) => {
        const total = summary.get(production.resource) ?? { produced: 0, consumed: 0 };
        total.produced += production.quantity;
        if (production.consumed) total.consumed += production.consumed;
        return summary.set(production.resource, total);
      }, new Map()),
  );

  let income = $derived(
    Array.from(summary)
      .map(
        ([resource, { produced, consumed }]) => resources[resource].value * (produced - consumed),
      )
      .reduce((a, b) => a + b, 0) / 10,
  );
</script>

<div class="area">
  <div class="status">
    <div class="title-area">
      <span class="title">Your Town</span>
      <span>${income.toFixed(2)} / day</span>
    </div>
    <div class="resource-area">
      {#each summary.entries() as [resource, { produced, consumed }] (resource)}
        <span>
          <ResourceRef id={resource} />
          {produced}/{consumed}
        </span>
      {/each}
    </div>
  </div>

  <div class="menu" role="toolbar">
    <a class="button" href="/">Menu</a>
    <button onclick={reset}>Reset</button>
    <button onclick={onClickDeck}>Deck</button>
  </div>
</div>

<DeckDialog bind:this={deckDialog} {onSelectCard} />
<CardRewardDialog bind:this={cardRewardDialog} />
<CardFocusDialog bind:this={cardFocusDialog} />

<svelte:window {oncardsreceived} {oncardfocus} />

<style>
  .area {
    pointer-events: none;
    position: relative;
    width: 100%;
    height: 100%;
    display: grid;

    grid-template:
      "status status" auto
      ". ." 1fr
      ". menu" auto
      / 1fr auto;
  }

  .menu {
    grid-area: menu;
    padding: 2rem;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .status {
    pointer-events: auto;
    grid-area: status;
    padding: 0.4rem;
    display: flex;
    flex-direction: row;
    gap: 1rem;
    justify-content: space-between;
    background-color: rgb(255 255 255 / 0.8);
    backdrop-filter: blur(1rem);
    border-bottom: 1px solid rgb(0 0 0 / 0.12);
    font-size: 0.8rem;
  }

  .title-area {
    display: flex;
    flex-direction: row;
    gap: 1rem;
  }

  .resource-area {
    display: flex;
    flex-direction: row;
    gap: 0.5rem;
  }

  .title {
    font-weight: 600;
  }

  button,
  a.button {
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 100%;
    width: 4rem;
    height: 4rem;
    background-color: rgb(0 0 0 / 0.7);
    backdrop-filter: blur(5px);
    color: white;
    pointer-events: auto;
    cursor: pointer;
    border: 1px solid rgb(0 0 0 / 0.12);
    box-shadow: 0 0 0.25rem rgb(0 0 0 / 0.25);
    font-size: 1rem;
  }
</style>
