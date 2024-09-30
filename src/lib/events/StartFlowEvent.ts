import type { ResourceType } from "$lib/data/resources";

export class StartFlowEvent extends Event {
  sourceType: "input" | "output";
  resource: ResourceType;
  clientX: number;
  clientY: number;

  constructor({
    resource,
    sourceType,
    clientX,
    clientY,
  }: {
    resource: ResourceType;
    sourceType: "input" | "output";
    clientX: number;
    clientY: number;
  }) {
    super("startflow");
    this.sourceType = sourceType;
    this.resource = resource;
    this.clientX = clientX;
    this.clientY = clientY;
  }
}
