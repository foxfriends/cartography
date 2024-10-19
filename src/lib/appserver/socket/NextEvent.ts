export class NextEvent<T> extends Event {
  message: T;

  constructor(message: T) {
    super("next");
    this.message = message;
  }
}
