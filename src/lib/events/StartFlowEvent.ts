import type { ResourceType } from "$lib/data/resources";

export class StartFlowEvent extends Event {
  sourceType: "input" | "output";
  resource: ResourceType;

  constructor(resource: ResourceType, sourceType: "input" | "output") {
    super("startflow");
    this.sourceType = sourceType;
    this.resource = resource;
  }
}
