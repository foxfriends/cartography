import { ReactiveEventTarget } from "$lib/ReactiveEventTarget.svelte";
import type { CardMessage, FieldCardMessage, FieldMessage } from "./Message";
import { MessageEvent } from "./MessageEvent";
import { NextEvent } from "./NextEvent";
import { type SocketV1 } from "./SocketV1";

interface SubscriptionEventMap<C extends Channel> {
  next: NextEvent<SubscriptionMessageMap[Topic<C>]>;
}

// eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
export type Channel = "deck" | "fields" | { topic: "field_cards"; field_id: number };

export type Topic<C extends Channel> = C extends string
  ? C
  : C extends { topic: infer T }
    ? T
    : never;

export interface SubscriptionMessageMap {
  fields: FieldMessage;
  deck: CardMessage;
  // eslint-disable-next-line @typescript-eslint/naming-convention -- this is a server owned field
  field_cards: FieldCardMessage;
}

export class Subscription<C extends Channel> extends ReactiveEventTarget<SubscriptionEventMap<C>> {
  #socket: SocketV1;
  #handler: (event: MessageEvent) => void;
  id: string;

  constructor(socket: SocketV1, id: string) {
    super();
    this.#socket = socket;
    this.id = id;

    this.#handler = (event: MessageEvent) => {
      if (event.message.id === this.id) {
        this.dispatchEvent(new NextEvent(event.message as SubscriptionMessageMap[Topic<C>]));
      }
    };

    this.#socket.addEventListener("message", this.#handler);
  }

  unsubscribe() {
    this.#socket.unsubscribe(this.id);
    this.#socket.removeEventListener("message", this.#handler);
  }
}
