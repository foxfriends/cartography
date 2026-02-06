import type { CardId } from "./Card";
import type { CitizenId } from "./Citizen";

export interface Employment {
  id: EmploymentId;
  citizen: CitizenId;
  workplace: CardId;
}

declare const __brand: unique symbol;
export type EmploymentId = string & { [__brand]: "EmploymentId" };

export function generateEmploymentId(): EmploymentId {
  return window.crypto.randomUUID() as EmploymentId;
}
