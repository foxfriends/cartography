import type { CardId } from "./Card";

export interface FieldCard {
  id: CardId;
  x: number;
  y: number;
  loose?: boolean;
}

export function indexById(field: FieldCard[]): Map<CardId, FieldCard> {
  return new Map(field.map((card) => [card.id, card]));
}

export function indexByPosition(field: FieldCard[]) {
  const index: FieldCard[][] = [];
  for (const card of field) {
    index[card.y] ??= [];
    index[card.y]![card.x] = card;
  }
  return {
    get(x: number, y: number) {
      return index[y]?.[x];
    },
  };
}
