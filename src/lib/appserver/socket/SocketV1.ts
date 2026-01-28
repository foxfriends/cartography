import { MessageEvent } from "./MessageEvent";
import { AuthEvent } from "./AuthEvent";
import { OneOff } from "./OneOff.svelte";
import { Subscription, type Channel } from "./Subscription";
import type { MessageReply } from "./Message";
import { ReactiveEventTarget } from "$lib/ReactiveEventTarget.svelte";
import type { FieldId } from "../Field";
import { Result$isOk, Result$Ok$0 } from "cartography-api/prelude";
import * as Request from "cartography-api/request";
import * as Response from "cartography-api/response";

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
      const message = Response.from_string(data);
      if (Result$isOk(message)) {
        this.dispatchEvent(new MessageEvent(Result$Ok$0(message)!));
      } else {
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

  #sendMessage<T extends Request.Request$>(request: T, id: string = window.crypto.randomUUID()) {
    this.#socket.send(Request.to_string(Request.message(request, id)));
    return new OneOff<MessageReply<T>>(this, id);
  }

  auth(data: { id: string }) {
    this.#sendMessage<Request.Authenticate>(Request.authenticate(data.id) as Request.Authenticate)
      .reply()
      .then((event) => {
        this.dispatchEvent(new AuthEvent(event[0]));
      });
  }

  close(code?: number, reason?: string) {
    this.#socket.close(code, reason);
  }
}
