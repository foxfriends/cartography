import type { DeckCard } from "$lib/types";

export class CardsReceivedEvent extends Event {
  cards: DeckCard[];

  constructor(cards: DeckCard[]) {
    super("cardsreceived");
    this.cards = cards;
  }
}
