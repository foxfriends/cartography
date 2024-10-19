import type { CardType } from "$lib/data/cards";

export interface Card {
  id: CardId;
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  card_type_id: CardType; // TODO: is this to be linked to database records? or to code...
}

declare const __brand: unique symbol;
export type CardId = string & { [__brand]: "CardId" };
