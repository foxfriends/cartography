import type { DeckCard } from "$lib/types";

export class CardReceivedEvent extends Event {
  card: DeckCard;

  constructor(card: DeckCard) {
    super("cardreceived");
    this.card = card;
  }
}
