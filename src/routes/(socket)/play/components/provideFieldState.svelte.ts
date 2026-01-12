import type { CardId } from "$lib/appserver/Card";
import type { Field, FieldId } from "$lib/appserver/Field";
import type { FieldTile } from "$lib/appserver/FieldTile";
import { getSocket } from "$lib/appserver/provideSocket.svelte";
import { getContext, setContext } from "svelte";
import { SvelteMap } from "svelte/reactivity";

const FIELD_STATE = Symbol("Field State");

interface FieldState {
  get fieldId(): FieldId | undefined;
  get field(): Field | undefined;
  get fieldTiles(): FieldTile[];
}

export function getFieldState() {
  const state = getContext(FIELD_STATE) as FieldState;
  return { ...state };
}

export function provideFieldState() {
  const socket = getSocket();

  let fieldId: FieldId | undefined = $state();
  let field: Field | undefined = $state();
  let fieldTiles = $state(new SvelteMap<CardId, FieldTile>());

  socket.$on("auth", () => {
    $effect(() => {
      if (fieldId) {
        // const subscription = socket.subscribe({ topic: "field_tiles", field_id: fieldId });

        socket.getField(fieldId).$then(({ data }) => {
          field = data.field;
          fieldTiles = new SvelteMap(data.field_tiles.map((tile) => [tile.tile_id, tile]));
        });

        // subscription.$on("next", ({ message }) => {
        //   fieldTiles.set(message.data.field_card.card_id, message.data.field_card);
        // });

        return () => {
          // subscription.unsubscribe();
        };
      }
    });
  });

  setContext(FIELD_STATE, {
    get fieldId() {
      return fieldId;
    },
    get field() {
      return field;
    },
    get fieldTiles() {
      return fieldTiles;
    },
  });

  return {
    set fieldId(value: FieldId | undefined) {
      fieldId = value;
    },
  };
}
