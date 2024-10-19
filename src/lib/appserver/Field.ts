/* eslint-disable @typescript-eslint/naming-convention */
export interface Field {
  id: FieldId;
  name: string;
  account_id: string;
  grid_x: number;
  grid_y: number;
  width: number;
  height: number;
}

declare const __brand: unique symbol;
export type FieldId = number & { [__brand]: "FieldId" };
