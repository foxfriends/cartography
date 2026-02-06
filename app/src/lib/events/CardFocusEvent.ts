export class CardFocusEvent extends Event {
  cardId: string;

  constructor(cardId: string) {
    super("cardfocus");
    this.cardId = cardId;
  }
}
