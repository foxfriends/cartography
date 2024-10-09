type Message = unknown;

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

  #sendMessage(type: string, data: unknown) {
    this.#socket.send(JSON.stringify({ type, data }));
  }

  auth(data: { id: string }) {
    this.#sendMessage("auth", data);
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
}
