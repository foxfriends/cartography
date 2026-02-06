import type { FlowId } from "$lib/engine/Flow";

export class DeleteFlowEvent extends Event {
  flow: FlowId;

  constructor(flow: FlowId) {
    super("deleteflow");
    this.flow = flow;
  }
}
