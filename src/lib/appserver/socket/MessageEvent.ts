import type { Message$ } from "cartography-api/response";

export class MessageEvent extends Event {
  message: Message$;

  constructor(message: Message$) {
    super("message");
    this.message = message;
  }
}
