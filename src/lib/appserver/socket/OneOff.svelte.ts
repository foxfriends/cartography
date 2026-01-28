import * as Response from "cartography-api/response";
import type { MessageEvent } from "./MessageEvent";
import { type SocketV1 } from "./SocketV1";

export class OneOff<T> extends EventTarget {
  #socket: SocketV1;
  id: string;

  constructor(socket: SocketV1, id: string) {
    super();
    this.#socket = socket;
    this.id = id;
  }

  async reply(abort?: AbortSignal) {
    return new Promise<T>((resolve, reject) => {
      abort?.throwIfAborted();

      const handler = (event: MessageEvent) => {
        if (Response.id(event.message) === this.id) {
          resolve(Response.response(event.message) as T);
          this.#socket.removeEventListener("message", handler);
          abort?.removeEventListener("abort", onabort);
        }
      };

      const onabort = () => {
        reject(abort!.reason);
        this.#socket.removeEventListener("message", handler);
      };

      this.#socket.addEventListener("message", handler);
      abort?.addEventListener("abort", onabort);
    });
  }

  $then(callback: (event: T) => void): void {
    $effect(() => {
      const abort = new AbortController();

      this.reply(abort.signal).then(
        (event) => {
          callback(event);
        },
        (error) => {
          if (error === "unmounted") return;
          throw error;
        },
      );

      return () => abort.abort("unmounted");
    });
  }
}
