import type { KeyboardEventHandler } from "svelte/elements";

type Handler<Args extends unknown[] = unknown[]> = (...args: Args) => void;
export function opt<Args extends unknown[], R>(
  modifier: (handler: Handler<Args>) => R,
): (handler: Handler<Args> | undefined) => R | undefined {
  return (handler: Handler<Args> | undefined) => (handler ? modifier(handler) : handler);
}

export function enter<Element extends EventTarget>(handler: KeyboardEventHandler<Element>) {
  return (event: KeyboardEvent & { currentTarget: Element }) => {
    if (event.key === "enter") handler(event);
  };
}

export function apply<Args extends unknown[]>(
  ...args: Args
): (handler: Handler<Args>) => Handler<[]> {
  return (handler: Handler<Args>) => () => handler(...args);
}
