export type Terrain = {
  type: string;
  name: string;
};

export const terrains = {
  soil: {
    type: "soil",
    name: "Soil",
  },
  grass: {
    type: "grass",
    name: "Grass",
  },
} as const satisfies Record<string, Terrain>;

export type TerrainType = keyof typeof terrains;
