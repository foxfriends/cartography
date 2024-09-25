export interface Resource {
  type: string;
  name: string;
  value: number;
}

export const resources = {
  water: {
    type: "water",
    name: "Water",
    value: 0,
  },
  wheat: {
    type: "wheat",
    name: "Wheat",
    value: 1,
  },
  lettuce: {
    type: "lettuce",
    name: "Lettuce",
    value: 1,
  },
  tomato: {
    type: "tomato",
    name: "Tomato",
    value: 1,
  },
  flour: {
    type: "flour",
    name: "Flour",
    value: 2,
  },
  bread: {
    type: "bread",
    name: "Bread",
    value: 5,
  },
  salad: {
    type: "salad",
    name: "Salad",
    value: 5,
  },
} as const satisfies Record<string, Resource>;

export type ResourceType = keyof typeof resources;
