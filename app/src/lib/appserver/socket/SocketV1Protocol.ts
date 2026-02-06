/* eslint-disable @typescript-eslint/naming-convention -- TypeBox schemas are more like types than values, so can be named using type format. */

/**
 * This is a handwritten translation of the `cardtography_api` Gleam package's interface.
 * When in doubt the Gleam code is authoritative and this end should be updated.
 */

import type { OpPatch } from "json-patch";
import Type, { type StaticDecode, type TSchema } from "typebox";

declare const __BRAND: unique symbol;
type Branded<Brand, T> = T & { [__BRAND]: Brand };

function Branded<Brand extends string, T extends TSchema>(brand: Brand, value: T) {
  return Type.Codec(value)
    .Decode((val) => val as Branded<Brand, StaticDecode<T>>)
    .Encode((val) => val as StaticDecode<T>);
}

function Struct<Tag extends string, Payload extends TSchema>(name: Tag, payload: Payload) {
  return Type.Object({
    "#type": Type.Literal("struct"),
    "#tag": Type.Literal(name),
    "#payload": payload,
  });
}

export function construct<Tag extends string, Payload>(tag: Tag, payload: Payload) {
  return { "#type": "struct", "#tag": tag, "#payload": payload } as const;
}

export type Struct<Tag extends string, Payload extends TSchema> = StaticDecode<
  typeof Struct<Tag, Payload>
>;

const JsonPointer = Type.String({
  pattern: "^(/[^/~]*(~[01][^/~]*)*)*$",
});

/**
 * Adapted from: https://github.com/fge/sample-json-schemas/blob/master/json-patch/json-patch.json
 */
const JsonPatchT = Type.Intersect(
  [
    Type.Object({ path: JsonPointer }, { description: "Members common to all operations" }),
    Type.Union([
      Type.Object(
        { op: Type.Literal("add"), value: Type.Unknown() },
        { description: "add operation. Value can be any JSON value." },
      ),
      Type.Object(
        { op: Type.Literal("remove") },
        { description: "remove operation. Only a path is specified." },
      ),
      Type.Object(
        { op: Type.Literal("replace"), value: Type.Unknown() },
        { description: "replace operation. Value can be any JSON value." },
      ),
      Type.Object(
        { op: Type.Literal("move"), from: JsonPointer },
        { description: 'move operation. "from" is a JSON Pointer.' },
      ),
      Type.Object(
        { op: Type.Literal("copy"), from: JsonPointer },
        { description: 'copy operation. "from" is a JSON Pointer.' },
      ),
      Type.Object(
        { op: Type.Literal("test"), value: Type.Unknown() },
        { description: "test operation. Value can be any JSON value." },
      ),
    ]),
  ],
  { description: "one JSON Patch operation" },
);

export const JsonPatch = Type.Codec(JsonPatchT)
  .Decode((value) => value as unknown as OpPatch)
  .Encode((value) => value as StaticDecode<typeof JsonPatchT>);

export const AccountId = Branded("AccountId", Type.String());
export type AccountId = StaticDecode<typeof AccountId>;

export const TileId = Branded("TileId", Type.Integer());
export type TileId = StaticDecode<typeof TileId>;

export const CitizenId = Branded("CitizenId", Type.Integer());
export type CitizenId = StaticDecode<typeof CitizenId>;

export const CardId = Type.Union([CitizenId, TileId]);
export type CardId = StaticDecode<typeof CardId>;

export const TileTypeId = Branded("TileTypeId", Type.String());
export type TileTypeId = StaticDecode<typeof TileTypeId>;

export const SpeciesId = Branded("SpeciesId", Type.String());
export type SpeciesId = StaticDecode<typeof SpeciesId>;

export const FieldId = Branded("FieldId", Type.Integer());
export type FieldId = StaticDecode<typeof FieldId>;

export const CardTypeId = Type.Union([TileTypeId, SpeciesId]);
export type CardTypeId = StaticDecode<typeof CardTypeId>;

export const Account = Type.Object({ id: AccountId });
export type Account = StaticDecode<typeof Account>;

export const Tile = Type.Object({ id: TileId, tile_type_id: TileTypeId, name: Type.String() });
export type Tile = StaticDecode<typeof Tile>;

export const Citizen = Type.Object({
  id: CitizenId,
  species_id: SpeciesId,
  name: Type.String(),
  home_tile_id: Type.Union([TileId, Type.Null()]),
});
export type Citizen = StaticDecode<typeof Citizen>;

export const FieldTile = Type.Object({ id: TileId, x: Type.Integer(), y: Type.Integer() });
export type FieldTile = StaticDecode<typeof FieldTile>;

export const FieldCitizen = Type.Object({ id: CitizenId, x: Type.Integer(), y: Type.Integer() });
export type FieldCitizen = StaticDecode<typeof FieldCitizen>;

export const Field = Type.Object({
  id: FieldId,
  name: Type.String(),
});
export type Field = StaticDecode<typeof Field>;

export const GameStateField = Type.Object({
  tiles: Type.Array(FieldTile),
  citizens: Type.Array(FieldCitizen),
});
export type GameStateField = StaticDecode<typeof GameStateField>;

export const GameState = Type.Object({
  deck: Type.Object({
    tiles: Type.Array(Tile),
    citizens: Type.Array(Citizen),
  }),
  field: GameStateField,
});
export type GameState = StaticDecode<typeof GameState>;

export const Authenticate = Struct("Authenticate", Type.String());
export type Authenticate = StaticDecode<typeof Authenticate>;

export const ListFields = Struct("ListFields", Type.Null());
export type ListFields = StaticDecode<typeof ListFields>;

export const WatchField = Struct("WatchField", FieldId);
export type WatchField = StaticDecode<typeof WatchField>;

export const Unsubscribe = Struct("Unsubscribe", Type.Null());
export type Unsubscribe = StaticDecode<typeof Unsubscribe>;

export const DebugAddCard = Struct("DebugAddCard", Type.String());
export type DebugAddCard = StaticDecode<typeof DebugAddCard>;

export const Request = Type.Union([
  Authenticate,
  ListFields,
  WatchField,
  Unsubscribe,
  DebugAddCard,
]);
export type Request = StaticDecode<typeof Request>;

export const Authenticated = Struct("Authenticated", Account);
export type Authenticated = StaticDecode<typeof Authenticated>;

export const Fields = Struct("Fields", Type.Array(Field));
export type Fields = StaticDecode<typeof Fields>;

export const PutState = Struct("PutState", GameState);
export type PutState = StaticDecode<typeof PutState>;

export const PatchState = Struct("PatchState", Type.Array(JsonPatch));
export type PatchState = StaticDecode<typeof PatchState>;

export const Response = Type.Union([Authenticated, Fields, PutState, PatchState]);
export type Response = StaticDecode<typeof Response>;

export type Once<T> = Branded<"Once", T>;
export type Stream<T> = Branded<"Stream", T>;

export type OnceType<T> = T extends Once<infer R> ? R : never;
export type StreamType<T> = T extends Stream<infer R> ? R : never;

export interface SocketV1Protocol {
  Authenticate: Once<Authenticated>;
  ListFields: Once<Fields>;
  WatchField: Stream<PutState | PatchState>;
}

export const RequestMessage = Type.Object({
  id: Type.String({ format: "uuid" }),
  request: Request,
});
export type RequestMessage = StaticDecode<typeof RequestMessage>;

export const ResponseMessage = Type.Object({
  id: Type.String({ format: "uuid" }),
  nonce: Type.Integer(),
  response: Response,
});
export type ResponseMessage = StaticDecode<typeof ResponseMessage>;
