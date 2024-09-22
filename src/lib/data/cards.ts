import type { ResourceType } from "./resources";
import type { SpeciesType } from "./species";
import type { TerrainType } from "./terrains";

type Source = { type: "terrain"; terrain: TerrainType } | { type: "any" };
type Output = { resource: ResourceType; quantity: number };
type Input = { resource: ResourceType; quantity: number };
type Population = { quantity: number; species: SpeciesType };

export interface BaseCard {
  name: string;
  type: string;
}

export interface SourceCard extends BaseCard {
  category: "source";
  source: Source[];
  outputs: Output[];
  employees: number;
}

export interface ResidentalCard extends BaseCard {
  category: "residential";
  population: Population[];
}

export interface ProductionCard extends BaseCard {
  category: "production";
  outputs: Output[];
  inputs: Input[];
  employees: number;
}

export interface TradeCard extends BaseCard {
  category: "trade";
}

export type Card = ProductionCard | SourceCard | ResidentalCard | TradeCard;

export type CardType = keyof typeof cards;

export const cards = {
  "trading-centre": { type: "trading-centre", name: "Trading Centre", category: "trade" },
  "trading-post": { type: "trading-post", name: "Trading Post", category: "trade" },
  "cat-neighbourhood": {
    type: "cat-neighbourhood",
    name: "Cat Neighbourhood",
    category: "residential",
    population: [{ quantity: 6, species: "cat" }],
  },
  "rabbit-neighbourhood": {
    type: "rabbit-neighbourhood",
    name: "Rabbit Neighbourhood",
    category: "residential",
    population: [{ quantity: 6, species: "rabbit" }],
  },
  "water-well": {
    type: "water-well",
    name: "Water Well",
    category: "source",
    employees: 1,
    source: [{ type: "any" }],
    outputs: [{ resource: "water", quantity: 10 }],
  },
  "wheat-farm": {
    type: "wheat-farm",
    name: "Wheat Farm",
    category: "source",
    employees: 4,
    source: [{ type: "terrain", terrain: "soil" }],
    outputs: [{ resource: "wheat", quantity: 4 }],
  },
  "lettuce-farm": {
    type: "lettuce-farm",
    name: "Lettuce Farm",
    category: "source",
    employees: 4,
    source: [{ type: "terrain", terrain: "soil" }],
    outputs: [{ resource: "lettuce", quantity: 4 }],
  },
  "tomato-farm": {
    type: "tomato-farm",
    name: "Tomato Farm",
    category: "source",
    employees: 4,
    source: [{ type: "terrain", terrain: "soil" }],
    outputs: [{ resource: "tomato", quantity: 4 }],
  },
  "flour-mill": {
    type: "flour-mill",
    name: "Flour Mill",
    category: "production",
    employees: 2,
    inputs: [{ resource: "wheat", quantity: 1 }],
    outputs: [{ resource: "flour", quantity: 5 }],
  },
  bakery: {
    type: "bakery",
    name: "Bakery",
    category: "production",
    employees: 2,
    inputs: [
      { resource: "water", quantity: 1 },
      { resource: "flour", quantity: 4 },
    ],
    outputs: [{ resource: "bread", quantity: 5 }],
  },
  "salad-shop": {
    type: "salad-shop",
    name: "Salad Shop",
    category: "production",
    employees: 2,
    inputs: [
      { resource: "tomato", quantity: 1 },
      { resource: "lettuce", quantity: 2 },
    ],
    outputs: [{ resource: "salad", quantity: 3 }],
  },
} as const satisfies Record<string, Card>;
