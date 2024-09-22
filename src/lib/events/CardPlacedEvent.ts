import type { FieldCard } from "$lib/engine/FieldCard";

export class CardPlacedEvent extends Event {
  card: FieldCard;

  constructor(card: FieldCard) {
    super("cardplaced");
    this.card = card;
  }
}
