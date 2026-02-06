import type { ResponseMessage } from "./SocketV1Protocol";

export class MessageEvent extends Event {
  message: ResponseMessage;

  constructor(message: ResponseMessage) {
    super("message");
    this.message = message;
  }
}
