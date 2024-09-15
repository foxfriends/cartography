type Source = { terrain: string };
type Output = { resource: string; quantity: number };
type Input = { resource: string; quantity: number };
type Population = { quantity: number; species: string };

type BaseCard = { name: string; type: string };
type ProductionCard = { category: "production"; source: Source[]; outputs: Output[] };
type SourceCard = { category: "source"; outputs: Output[] };
type ResidentalCard = { category: "residential"; population: Population[] };
type CommercialCard = { category: "commercial"; outputs: Output[]; inputs: Input[] };
type TradeCard = { category: "trade" };

export type Card = BaseCard &
  (ProductionCard | SourceCard | ResidentalCard | CommercialCard | TradeCard);

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
    outputs: [{ resource: "water", quantity: 10 }],
  },
  "wheat-farm": {
    type: "wheat-farm",
    name: "Wheat Farm",
    category: "production",
    source: [{ terrain: "soil" }],
    outputs: [{ resource: "wheat", quantity: 4 }],
  },
  "lettuce-farm": {
    type: "lettuce-farm",
    name: "Lettuce Farm",
    category: "production",
    source: [{ terrain: "soil" }],
    outputs: [{ resource: "lettuce", quantity: 4 }],
  },
  "tomato-farm": {
    type: "tomato-farm",
    name: "Tomato Farm",
    category: "production",
    source: [{ terrain: "soil" }],
    outputs: [{ resource: "tomato", quantity: 4 }],
  },
  "flour-mill": {
    type: "flour-mill",
    name: "Flour Mill",
    category: "commercial",
    inputs: [{ resource: "wheat", quantity: 1 }],
    outputs: [{ resource: "flour", quantity: 5 }],
  },
  bakery: {
    type: "bakery",
    name: "Bakery",
    category: "commercial",
    inputs: [
      { resource: "water", quantity: 1 },
      { resource: "flour", quantity: 4 },
    ],
    outputs: [{ resource: "bread", quantity: 5 }],
  },
  "salad-shop": {
    type: "salad-shop",
    name: "Salad Shop",
    category: "commercial",
    inputs: [
      { resource: "tomato", quantity: 1 },
      { resource: "lettuce", quantity: 2 },
    ],
    outputs: [{ resource: "salad", quantity: 3 }],
  },
} as const satisfies Record<string, Card>;