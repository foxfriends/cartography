export class CloseEvent extends Event {
  reason: string;

  constructor(reason: string) {
    super("close");
    this.reason = reason;
  }
}
