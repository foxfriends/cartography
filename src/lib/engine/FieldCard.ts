import { nearestEdgeDistance } from "$lib/algorithm/nearestEdge";
import { rangeInclusive } from "$lib/algorithm/range";
import type { CardId } from "./Card";

export type FieldCard = { id: CardId; x: number; y: number; loose?: boolean };
export type Field = FieldCard[];

export function indexById(field: Field): Map<string, FieldCard> {
  return new Map(field.map((card) => [card.id, card]));
}

export function indexByPosition(field: Field) {
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

const TRANSPORTATION_RANGE = 2;
export function isInRange(lhs: FieldCard, rhs: FieldCard) {
  return nearestEdgeDistance(lhs, rhs) <= TRANSPORTATION_RANGE;
}

export function* coordinatesInRange({ x, y }: FieldCard): Generator<[x: number, y: number]> {
  for (const yy of rangeInclusive(y - TRANSPORTATION_RANGE, y + TRANSPORTATION_RANGE)) {
    for (const xx of rangeInclusive(x - TRANSPORTATION_RANGE, x + TRANSPORTATION_RANGE)) {
      yield [xx, yy];
    }
  }
}
