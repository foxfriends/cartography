import type { DeckCard } from "$lib/engine/DeckCard";

export class CardFieldedEvent extends Event {
  card: DeckCard;

  constructor(card: DeckCard) {
    super("cardfielded");
    this.card = card;
  }
}
