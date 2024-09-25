import type { CardType } from "$lib/data/cards";
import type { CardId } from "./Card";

export interface DeckCard { id: CardId; type: CardType }
export type Deck = DeckCard[];

export function indexById(field: Deck): Map<string, DeckCard> {
  return new Map(field.map((card) => [card.id, card]));
}
