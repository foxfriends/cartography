import type { ResourceType } from "./resources";

interface Need { type: "resource"; resource: ResourceType; quantity: number }

export interface Species {
  type: string;
  name: string;
  namePlural: string;
  needs: Need[];
}

export const species = {
  cat: {
    type: "cat",
    name: "Cat",
    namePlural: "Cats",
    needs: [{ type: "resource", resource: "bread", quantity: 1 }],
  },
  rabbit: {
    type: "rabbit",
    name: "Rabbit",
    namePlural: "Rabbits",
    needs: [{ type: "resource", resource: "salad", quantity: 1 }],
  },
} as const satisfies Record<string, Species>;

export type SpeciesType = keyof typeof species;
