import type { Account } from "../Account";

export interface MessageReplyMap {
  auth: AccountMessage;
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
  data: Account;
}

export interface FieldMessage extends AnyMessage {
  type: "field";
}

export interface FieldCardMessage extends AnyMessage {
  type: "field_card";
}

export interface CardAccountMessage extends AnyMessage {
  type: "card_account";
}

export type Message = AccountMessage | FieldMessage | CardAccountMessage | FieldCardMessage;
