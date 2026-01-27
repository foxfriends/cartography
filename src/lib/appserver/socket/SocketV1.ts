import { MessageEvent } from "./MessageEvent";
import { AuthEvent } from "./AuthEvent";
import { OneOff } from "./OneOff.svelte";
import { Subscription, type Channel } from "./Subscription";
import type { Message, MessageReplyMap } from "./Message";
import { ReactiveEventTarget } from "$lib/ReactiveEventTarget.svelte";
import type { FieldId } from "../Field";
import { type Request$ } from "cartography-api/request";

interface SocketV1EventMap {
  message: MessageEvent;
  error: Event;
  close: CloseEvent;
  auth: AuthEvent;
}

export class SocketV1 extends ReactiveEventTarget<SocketV1EventMap> {
  static readonly PROTOCOL = ["v1.cartography.app"];

  #socket: WebSocket;
  #url: string;

  constructor(url: string) {
    super();
    this.#url = url;

    this.#socket = new WebSocket(this.#url, SocketV1.PROTOCOL);
    this.#watchSocket();
  }

  #watchSocket() {
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
        const message = JSON.parse(data) as Message;
        this.dispatchEvent(new MessageEvent(message));
      } catch {
        this.#socket.close(4000, "Invalid JSON received");
        this.dispatchEvent(new Event("error"));
      }
    });

    const reconnect = () => {
      this.#socket.removeEventListener("error", onError);
      this.#socket.removeEventListener("close", onClose);
      this.#socket = new WebSocket(this.#url, SocketV1.PROTOCOL);
      this.#watchSocket();
    };

    const onError = (event: Event) => {
      // eslint-disable-next-line no-console
      console.error("Socket error", event);
      this.dispatchEvent(new Event("error", event));
      reconnect();
    };

    const onClose = (event: CloseEvent) => {
      // eslint-disable-next-line no-console
      console.log("Socket closed", event);
      this.dispatchEvent(new CloseEvent("close", event));
      if (!event.wasClean) reconnect();
    };

    this.#socket.addEventListener("error", onError);
    this.#socket.addEventListener("close", onClose);
  }

  #sendMessage<T extends keyof MessageReplyMap>(
    type: T,
    data: unknown = {},
    id: string = window.crypto.randomUUID(),
  ) {
    this.#socket.send(JSON.stringify({ type, data, id }));
    return new OneOff<T>(this, id);
  }

  auth(data: { id: string }) {
    this.#sendMessage("auth", data)
      .reply()
      .then((event) => {
        this.dispatchEvent(new AuthEvent(event.data.account));
      });
  }

  getFields() {
    return this.#sendMessage("get_fields");
  }

  getField(id: FieldId) {
    return this.#sendMessage("get_field", { field_id: id });
  }

  unsubscribe(id: string) {
    this.#sendMessage("unsubscribe", {}, id);
  }

  subscribe<C extends Channel>(channel: C) {
    const id = window.crypto.randomUUID();
    this.#sendMessage("subscribe", { channel }, id);
    return new Subscription<C>(this, id);
  }

  close(code?: number, reason?: string) {
    this.#socket.close(code, reason);
  }
}
