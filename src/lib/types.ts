export type Geography = {
  biome: string;
  origin: { x: number; y: number };
  terrain: { type: string }[][];
  resources: { id: string; x: number; y: number }[];
};
