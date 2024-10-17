interface Message {
  type: string;
  id: string;
  data: unknown;
}

export class MessageEvent extends Event {
  message: Message;

  constructor(message: Message) {
    super("message");
    this.message = message;
  }
}

interface SocketV1EventMap {
  message: MessageEvent;
  error: Event;
  close: CloseEvent;
}

// eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
type Channel = "deck" | "fields" | { topic: "field_cards"; field_id: number };

export class SocketV1 extends EventTarget {
  #socket: WebSocket;

  constructor(url: string) {
    super();

    this.#socket = new WebSocket(url, ["v1.cartography.app"]);

    this.#socket.addEventListener("open", () => {
      this.auth({ id: "foxfriends" });
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
      this.dispatchEvent(event);
    });

    this.#socket.addEventListener("error", (event) => {
      // eslint-disable-next-line no-console
      console.log("Socket error", event);
      this.dispatchEvent(event);
    });
  }

  #sendMessage(type: string, data: unknown, id: string = window.crypto.randomUUID()) {
    this.#socket.send(JSON.stringify({ type, data, id }));
  }

  auth(data: { id: string }) {
    this.#sendMessage("auth", data);
  }

  unsubscribe(id: string) {
    this.#sendMessage("unsubscribe", {}, id);
  }

  subscribe(channel: Channel) {
    const id = window.crypto.randomUUID();
    this.#sendMessage("subscribe", { channel }, id);
    return new Subscription(this, id);
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
}

class Subscription extends EventTarget {
  #socket: SocketV1;
  #handler: (event: MessageEvent) => void;
  id: string;

  constructor(socket: SocketV1, id: string) {
    super();
    this.#socket = socket;
    this.id = id;

    this.#handler = (event: MessageEvent) => {
      if (event.message.id === this.id) this.dispatchEvent(event);
    };

    this.#socket.addEventListener("message", this.#handler);
  }

  unsubscribe() {
    this.#socket.unsubscribe(this.id);
    this.#socket.removeEventListener("message", this.#handler);
  }
}
