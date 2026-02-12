import { Branded } from "$lib/types";
import Type, { type StaticDecode } from "typebox";

// eslint-disable-next-line @typescript-eslint/naming-convention -- TypeBox types are named like types */
export const Field = Type.Object({
  id: Type.Integer(),
  name: Type.String(),
});
export type Field = StaticDecode<typeof Field>;
