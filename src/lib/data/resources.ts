export type Resource = {
  type: string;
  name: string;
};

export const resources = {
  water: {
    type: "water",
    name: "Water",
  },
  wheat: {
    type: "wheat",
    name: "Wheat",
  },
  lettuce: {
    type: "lettuce",
    name: "Lettuce",
  },
  tomato: {
    type: "tomato",
    name: "Tomato",
  },
  flour: {
    type: "flour",
    name: "Flour",
  },
  bread: {
    type: "bread",
    name: "Bread",
  },
  salad: {
    type: "salad",
    name: "Salad",
  },
} as const satisfies Record<string, Resource>;

export type ResourceType = keyof typeof resources;
