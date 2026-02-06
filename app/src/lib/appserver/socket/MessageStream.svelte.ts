import type { MessageEvent } from "./MessageEvent";
import { type SocketV1 } from "./SocketV1.svelte";
import type { OnceType, StreamType } from "./SocketV1Protocol";

export class MessageStream<T> extends EventTarget {
  #socket: SocketV1;
  id: string;

  constructor(socket: SocketV1, id: string) {
    super();
    this.#socket = socket;
    this.id = id;
  }

  async reply(abort?: AbortSignal) {
    return new Promise<OnceType<T>>((resolve, reject) => {
      abort?.throwIfAborted();

      const handler = (event: MessageEvent) => {
        if (event.message.id === this.id) {
          // NOTE: would be nice to do a runtime assertion here, but the mapping is currently
          // only defined as a type. Not hard to shift to a value, just lazy.
          resolve(event.message.response as OnceType<T>);
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

  replies(callback: (message: StreamType<T>) => void) {
    const handler = (event: MessageEvent) => {
      if (event.message.id === this.id) {
        // NOTE: would be nice to do a runtime assertion here, but the mapping is currently
        // only defined as a type. Not hard to shift to a value, just lazy.
        callback(event.message.response as StreamType<T>);
      }
    };

    return {
      unsubscribe: () => {
        this.#socket.unsubscribe(this.id);
        this.#socket.removeEventListener("message", handler);
      },
    };
  }

  $then(callback: (event: OnceType<T>) => void): void {
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

  $subscribe(callback: (event: StreamType<T>) => void): void {
    $effect(() => {
      const subscription = this.replies(callback);
      return () => subscription.unsubscribe();
    });
  }
}
