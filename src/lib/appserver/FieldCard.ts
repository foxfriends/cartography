import type { AccountId } from "./Account";
import type { CardId } from "./Card";
import type { FieldId } from "./Field";

export interface FieldCard {
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  account_id: AccountId;
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  card_id: CardId;
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  field_id?: FieldId;
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  grid_x?: number;
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  grid_y?: number;
}
