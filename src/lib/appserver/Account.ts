export interface Account {
  id: AccountId;
}

declare const __brand: unique symbol;
export type AccountId = string & { [__brand]: "AccountId" };
