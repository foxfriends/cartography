import { MessageEvent } from "./MessageEvent";
import { AuthEvent } from "./AuthEvent";
import { MessageStream } from "./MessageStream.svelte";
import { ReactiveEventTarget } from "$lib/ReactiveEventTarget.svelte";
import Value from "typebox/value";
import {
  Account,
  construct,
  Field,
  FieldId,
  GameState,
  Request,
  RequestMessage,
  ResponseMessage,
  type SocketV1Protocol,
} from "./SocketV1Protocol";
import jsonpatch from "json-patch";

interface SocketV1EventMap {
  message: MessageEvent;
  error: Event;
  close: CloseEvent;
  auth: AuthEvent;
}

export class SocketV1 extends ReactiveEventTarget<SocketV1EventMap> {
  static readonly PROTOCOL = ["v1-json.cartography.app", "v1-messagepack.cartography.app"];

  #socket: WebSocket;
  #url: string;

  account: Account | undefined = $state();

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
        const message = Value.Decode(ResponseMessage, JSON.parse(data));
        this.dispatchEvent(new MessageEvent(message));
      } catch (error) {
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

  #sendMessage<T extends Request>(request: T, id: string = window.crypto.randomUUID()) {
    const encoded = Value.Encode(RequestMessage, { id, request });
    this.#socket.send(JSON.stringify(encoded));
    return new MessageStream<
      T["#tag"] extends keyof SocketV1Protocol ? SocketV1Protocol[T["#tag"]] : never
    >(this, id);
  }

  auth(data: { id: string }) {
    this.#sendMessage(construct("Authenticate", data.id))
      .reply()
      .then((event) => {
        this.account = event["#payload"];
        this.dispatchEvent(new AuthEvent(event["#payload"]));
      });
  }

  async listFields(): Promise<Field[]> {
    const event = await this.#sendMessage(construct("ListFields", null)).reply();
    return event["#payload"];
  }

  $watchField(data: { id: FieldId }, subscriber: (gameState: GameState | undefined) => void) {
    let gameState: GameState | undefined = undefined;
    this.#sendMessage(construct("WatchField", data.id)).$subscribe((response) => {
      if (response["#tag"] === "PutState") {
        gameState = response["#payload"];
      } else if (response["#tag"] === "PatchState") {
        const patches = response["#payload"];
        gameState = jsonpatch.apply(gameState, patches);
      }
      subscriber(gameState);
    });
  }

  unsubscribe(id: string) {
    this.#sendMessage(construct("Unsubscribe", null), id);
  }

  close(code?: number, reason?: string) {
    this.#socket.close(code, reason);
  }
}
