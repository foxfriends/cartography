import type { DeckCard } from "$lib/engine/DeckCard";

export class CardsReceivedEvent extends Event {
  cards: DeckCard[];

  constructor(cards: DeckCard[]) {
    super("cardsreceived");
    this.cards = cards;
  }
}
