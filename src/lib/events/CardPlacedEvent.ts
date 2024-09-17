import type { FieldCard } from "$lib/types";

export class CardPlacedEvent extends Event {
  card: FieldCard;

  constructor(card: FieldCard) {
    super("cardplaced");
    this.card = card;
  }
}
