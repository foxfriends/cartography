import type { Flow } from "$lib/engine/Flow";

export class CreateFlowEvent extends Event {
  flow: Flow;

  constructor(flow: Flow) {
    super("createflow");
    this.flow = flow;
  }
}
