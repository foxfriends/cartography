import type { Message } from "./Message";

export class MessageEvent extends Event {
  message: Message;

  constructor(message: Message) {
    super("message");
    this.message = message;
  }
}
