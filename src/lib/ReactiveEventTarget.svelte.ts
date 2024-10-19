export abstract class ReactiveEventTarget<EventMap> extends EventTarget {
  addEventListener<K extends keyof EventMap>(
    type: K,
    listener: (this: ReactiveEventTarget<EventMap>, ev: EventMap[K]) => unknown,
    options?: boolean | AddEventListenerOptions,
  ): void;
  addEventListener(
    type: string,
    listener: EventListenerOrEventListenerObject,
    options?: boolean | AddEventListenerOptions,
  ): void;
  addEventListener(
    type: string | symbol | number,
    listener:
      | ((this: ReactiveEventTarget<EventMap>, ev: EventMap[keyof EventMap]) => unknown)
      | EventListenerOrEventListenerObject,
    options?: boolean | EventListenerOptions,
  ): void {
    super.addEventListener(type as string, listener as EventListenerOrEventListenerObject, options);
  }

  removeEventListener<K extends keyof EventMap>(
    type: K,
    listener: (this: ReactiveEventTarget<EventMap>, ev: EventMap[K]) => unknown,
    options?: boolean | EventListenerOptions,
  ): void;
  removeEventListener(
    type: string,
    listener: EventListenerOrEventListenerObject,
    options?: boolean | EventListenerOptions,
  ): void;
  removeEventListener(
    type: string | symbol | number,
    listener:
      | ((this: ReactiveEventTarget<EventMap>, ev: EventMap[keyof EventMap]) => unknown)
      | EventListenerOrEventListenerObject,
    options?: boolean | EventListenerOptions,
  ): void {
    super.removeEventListener(
      type as string,
      listener as EventListenerOrEventListenerObject,
      options,
    );
  }

  $on<K extends keyof EventMap>(
    type: K,
    listener: (this: ReactiveEventTarget<EventMap>, ev: EventMap[K]) => void | (() => void),
    options?: boolean | EventListenerOptions,
  ): void {
    $effect(() => {
      let cleanup: undefined | (() => void);

      function eventListener(this: ReactiveEventTarget<EventMap>, event: EventMap[K]) {
        cleanup?.();
        cleanup = $effect.root(() => {
          return listener.call(this, event);
        });
      }

      this.addEventListener(type, eventListener, options);
      return () => {
        cleanup?.();
        this.removeEventListener(type, eventListener, options);
      };
    });
  }
}
