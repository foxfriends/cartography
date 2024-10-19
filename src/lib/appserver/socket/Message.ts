import type { Account } from "../Account";
import type { Field } from "../Field";
import type { FieldCard } from "../FieldCard";
import type { Card } from "../Card";

export interface MessageReplyMap {
  auth: AccountMessage;
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  get_fields: FieldsMessage;
  subscribe: never;
  unsubscribe: never;
}

export interface AnyMessage {
  type: string;
  id: string;
  data: unknown;
}

export interface AccountMessage extends AnyMessage {
  type: "account";
  data: { account: Account };
}

export interface FieldMessage extends AnyMessage {
  type: "field";
  data: { field: Field };
}

export interface FieldsMessage extends AnyMessage {
  type: "field";
  data: { fields: Field[] };
}

export interface FieldCardMessage extends AnyMessage {
  type: "field_card";
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  data: { field_card: FieldCard };
}

export interface CardMessage extends AnyMessage {
  type: "card";
  data: { card: Card };
}

export type Message = AccountMessage | FieldMessage | CardMessage | FieldCardMessage;
