import type { Account } from "../Account";

export class AuthEvent extends Event {
  account: Account;

  constructor(account: Account) {
    super("auth");
    this.account = account;
  }
}
