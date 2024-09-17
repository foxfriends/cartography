import type { DeckCard } from "$lib/types";

export class CardFieldedEvent extends Event {
  card: DeckCard;

  constructor(card: DeckCard) {
    super("cardfielded");
    this.card = card;
  }
}
