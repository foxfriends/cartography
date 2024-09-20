<script lang="ts">
  import { cards, type Card } from "$lib/data/cards";
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
  import type { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
  import type { DeckCard } from "$lib/types";
  import CardRewardDialog from "./CardRewardDialog.svelte";
  import DeckDialog from "./DeckDialog.svelte";
  import { resources, type ResourceType } from "$lib/data/resources";

  let { deck, field, geography } = getGameState();

  let deckDialog: DeckDialog | undefined = $state();
  let cardRewardDialog: CardRewardDialog | undefined = $state();

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

  let excess: { resource: ResourceType; quantity: number }[] = $derived.by(() => {
    const cardsOnField = field
      .filter((fc) => !fc.loose)
      .map((fc) => ({ field: fc, deck: deck.find((dc) => dc.id === fc.id)! }))
      .map((fdc) => ({ ...fdc, card: cards[fdc.deck.type] }));

    const produced: Partial<
      Record<ResourceType, { producerId: string; x: number; y: number; quantity: number }[]>
    > = {};

    const producing = cardsOnField.filter(({ card }) => card.category === "source");
    const remaining = cardsOnField.filter(({ card }) => card.category === "production");
    nextCard: while (producing.length > 0) {
      const current = producing.shift()!;
      switch (current.card.category) {
        case "production":
          break;
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
        produced[output.resource] ??= [];
        produced[output.resource]!.push({
          producerId: current.deck.id,
          x: current.field.x,
          y: current.field.y,
          quantity: output.quantity,
        });
      }
    }

    return [];
  });
  let income = $derived(
    Math.floor(
      excess.map((res) => resources[res.resource].value * res.quantity).reduce((a, b) => a + b, 0) /
        10,
    ),
  );
</script>

<div class="area">
  <div class="status">
    <div class="title-area">
      <span class="title">Your Town</span>
      <span>${income} / day</span>
    </div>
    <div>Resource Display</div>
  </div>

  <div class="menu" role="toolbar">
    <a class="button" href="/">Menu</a>
    <button onclick={reset}>Reset</button>
    <button onclick={onClickDeck}>Deck</button>
  </div>
</div>

<DeckDialog bind:this={deckDialog} {onSelectCard} />
<CardRewardDialog bind:this={cardRewardDialog} />

<svelte:window {oncardsreceived} />

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
