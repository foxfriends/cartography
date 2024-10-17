import { MessageEvent } from "./MessageEvent";
import { type SocketV1 } from "./SocketV1";

interface SubscriptionEventMap {
  message: MessageEvent;
}

export class Subscription extends EventTarget {
  #socket: SocketV1;
  #handler: (event: MessageEvent) => void;
  id: string;

  constructor(socket: SocketV1, id: string) {
    super();
    this.#socket = socket;
    this.id = id;

    this.#handler = (event: MessageEvent) => {
      if (event.message.id === this.id) this.dispatchEvent(new MessageEvent(event.message));
    };

    this.#socket.addEventListener("message", this.#handler);
  }

  unsubscribe() {
    this.#socket.unsubscribe(this.id);
    this.#socket.removeEventListener("message", this.#handler);
  }

  addEventListener<K extends keyof SubscriptionEventMap>(
    type: K,
    listener: (this: SocketV1, ev: SubscriptionEventMap[K]) => unknown,
    options?: boolean | AddEventListenerOptions,
  ): void;
  addEventListener(
    type: string,
    listener: EventListenerOrEventListenerObject,
    options?: boolean | AddEventListenerOptions,
  ): void;
  addEventListener(
    type: string,
    listener: EventListenerOrEventListenerObject,
    options?: boolean | AddEventListenerOptions,
  ) {
    super.addEventListener(type, listener, options);
  }

  removeEventListener<K extends keyof SubscriptionEventMap>(
    type: K,
    listener: (this: WebSocket, ev: SubscriptionEventMap[K]) => unknown,
    options?: boolean | EventListenerOptions,
  ): void;
  removeEventListener(
    type: string,
    listener: EventListenerOrEventListenerObject,
    options?: boolean | EventListenerOptions,
  ): void;
  removeEventListener(
    type: string,
    listener: EventListenerOrEventListenerObject,
    options?: boolean | EventListenerOptions,
  ): void {
    super.removeEventListener(type, listener, options);
  }
}
