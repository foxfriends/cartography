import { species, type SpeciesType } from "$lib/data/species";
import type { CardId } from "./Card";

export interface Citizen {
  id: CitizenId;
  homeCard: CardId;
  species: SpeciesType;
  name: string;
}

declare const __brand: unique symbol;
export type CitizenId = string & { [__brand]: "CitizenId" };

export function generateCitizenId(): CitizenId {
  return window.crypto.randomUUID() as CitizenId;
}

export function createCitizen(homeCard: CardId, speciesType: SpeciesType) {
  const { name } = species[speciesType];
  return { id: generateCitizenId(), homeCard, species: speciesType, name };
}
