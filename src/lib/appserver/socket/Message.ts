/* eslint-disable @typescript-eslint/naming-convention -- this is a server owned field */

import type { Account } from "../Account";
import type { Field } from "../Field";
import type { FieldCard } from "../FieldCard";
import type { Card } from "../Card";

export interface MessageReplyMap {
  auth: AccountMessage;
  get_fields: FieldsMessage;
  get_field: FieldMessage;
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
  data: { field: Field; field_cards: FieldCard[] };
}

export interface FieldsMessage extends AnyMessage {
  type: "field";
  data: { fields: Field[] };
}

export interface FieldCardMessage extends AnyMessage {
  type: "field_card";

  data: { field_card: FieldCard };
}

export interface CardMessage extends AnyMessage {
  type: "card";
  data: { card: Card };
}

export type Message =
  | AccountMessage
  | FieldMessage
  | CardMessage
  | FieldCardMessage
  | FieldsMessage;
