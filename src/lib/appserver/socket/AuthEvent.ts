import type { Account } from "cartography-api/account";

export class AuthEvent extends Event {
  account: Account;

  constructor(account: Account) {
    super("auth");
    this.account = account;
  }
}
