import Type, { type StaticDecode, type TSchema } from "typebox";

declare const __BRAND: unique symbol;
export type Branded<Brand, T> = T & { [__BRAND]: Brand };

// eslint-disable-next-line @typescript-eslint/naming-convention -- TypeBox types are named like types */
export function Branded<Brand extends string, T extends TSchema>(brand: Brand, value: T) {
  return Type.Codec(value)
    .Decode((val) => val as Branded<Brand, StaticDecode<T>>)
    .Encode((val) => val as StaticDecode<T>);
}

export interface Geography {
  biome: string;
  origin: { x: number; y: number };
  terrain: { type: string }[][];
}
