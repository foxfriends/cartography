export type DeckCard = { id: string; type: string };
export type Deck = DeckCard[];

export type FieldCard = { id: string; x: number; y: number; loose?: boolean };
export type Field = FieldCard[];

export type Geography = {
  biome: string;
  origin: { x: number; y: number };
  terrain: { type: string }[][];
  resources: { id: string; x: number; y: number }[];
};
