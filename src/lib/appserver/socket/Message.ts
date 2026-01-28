/* eslint-disable @typescript-eslint/naming-convention -- this is a server owned field */

import type { Authenticate, DebugAddCard } from "cartography-api/request";
import type { Authenticated, PatchData } from "cartography-api/response";

export type MessageReply<T> = T extends Authenticate
  ? Authenticated
  : T extends DebugAddCard
    ? PatchData
    : void;
