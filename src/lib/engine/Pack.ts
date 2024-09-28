import type { CardCategory, CardType } from "$lib/data/cards";

type PackItem =
  | { type: "card"; card: CardType; missing?: true }
  | { type: "category"; category: CardCategory }
  | { type: "any" };

export interface Pack {
  id: string;
  name: string;
  description?: string;
  price: number;
  originalPrice?: number;
  contents: PackItem[];
}
