import type { Account } from "./SocketV1Protocol";

export class AuthEvent extends Event {
  account: Account;

  constructor(account: Account) {
    super("auth");
    this.account = account;
  }
}
