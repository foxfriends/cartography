import { CloseEvent } from "./CloseEvent";
import { MessageEvent } from "./MessageEvent";
import { AuthEvent } from "./AuthEvent";
import { OneOff } from "./OneOff";
import { Subscription, type Channel } from "./Subscription";
import type { MessageReplyMap } from "./Message";

interface SocketV1EventMap {
  message: MessageEvent;
  error: Event;
  close: CloseEvent;
  auth: AuthEvent;
}

export class SocketV1 extends EventTarget {
  #socket: WebSocket;

  constructor(url: string) {
    super();

    this.#socket = new WebSocket(url, ["v1.cartography.app"]);

    this.#socket.addEventListener("open", (event) => {
      // eslint-disable-next-line no-console
      console.log("Socket opened", event);
      this.dispatchEvent(new Event("open"));
    });

    this.#socket.addEventListener("message", (event) => {
      const data = event.data;
      if (typeof data !== "string") {
        this.#socket.close(1003, "Only text messages are supported");
        this.dispatchEvent(new Event("error"));
      }
      try {
        const message = JSON.parse(data);
        this.dispatchEvent(new MessageEvent(message));
      } catch {
        this.#socket.close(4000, "Invalid JSON received");
        this.dispatchEvent(new Event("error"));
      }
    });

    this.#socket.addEventListener("close", (event) => {
      // eslint-disable-next-line no-console
      console.log("Socket closed", event);
      this.dispatchEvent(new CloseEvent(event.reason));
    });

    this.#socket.addEventListener("error", (event) => {
      // eslint-disable-next-line no-console
      console.log("Socket error", event);
      this.dispatchEvent(new Event("error"));
    });
  }

  #sendMessage<T extends keyof MessageReplyMap>(
    type: T,
    data: unknown,
    id: string = window.crypto.randomUUID(),
  ) {
    this.#socket.send(JSON.stringify({ type, data, id }));
    return new OneOff<T>(this, id);
  }

  auth(data: { id: string }) {
    this.#sendMessage("auth", data)
      .reply()
      .then((event) => {
        this.dispatchEvent(new AuthEvent(event.data));
      });
  }

  unsubscribe(id: string) {
    this.#sendMessage("unsubscribe", {}, id);
  }

  subscribe<C extends Channel>(channel: C) {
    const id = window.crypto.randomUUID();
    this.#sendMessage("subscribe", { channel }, id);
    return new Subscription<C>(this, id);
  }

  addEventListener<K extends keyof SocketV1EventMap>(
    type: K,
    listener: (this: SocketV1, ev: SocketV1EventMap[K]) => unknown,
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

  removeEventListener<K extends keyof SocketV1EventMap>(
    type: K,
    listener: (this: WebSocket, ev: SocketV1EventMap[K]) => unknown,
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

  close(code?: number, reason?: string) {
    this.#socket.close(code, reason);
  }
}
