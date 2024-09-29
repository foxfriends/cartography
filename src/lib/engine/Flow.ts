import type { ResourceType } from "$lib/data/resources";
import type { CardId } from "./Card";

export interface Flow {
  id: FlowId;
  resource: ResourceType;
  source: CardId;
  destination: CardId;
  priority: number;
}

declare const __brand: unique symbol;
export type FlowId = string & { [__brand]: "FlowId" };

export function generateFlowId(): FlowId {
  return window.crypto.randomUUID() as FlowId;
}
