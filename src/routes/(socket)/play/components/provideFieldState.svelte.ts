import type { CardId } from "$lib/appserver/Card";
import type { Field, FieldId } from "$lib/appserver/Field";
import type { FieldCard } from "$lib/appserver/FieldCard";
import { getSocket } from "$lib/appserver/provideSocket.svelte";
import { getContext, setContext } from "svelte";
import { SvelteMap } from "svelte/reactivity";

const FIELD_STATE = Symbol("Field State");

interface FieldState {
  get fieldId(): FieldId | undefined;
  get field(): Field | undefined;
  get fieldCards(): FieldCard[];
}

export function getFieldState() {
  const state = getContext(FIELD_STATE) as FieldState;
  return { ...state };
}

export function provideFieldState() {
  const socket = getSocket();

  let fieldId: FieldId | undefined = $state();
  let field: Field | undefined = $state();
  let fieldCards = $state(new SvelteMap<CardId, FieldCard>());

  socket.$on("auth", () => {
    $effect(() => {
      if (fieldId) {
        // const subscription = socket.subscribe({ topic: "field_cards", field_id: fieldId });

        socket.getField(fieldId).$then(({ data }) => {
          field = data.field;
          fieldCards = new SvelteMap(data.field_cards.map((card) => [card.card_id, card]));
        });

        // subscription.$on("next", ({ message }) => {
        //   fieldCards.set(message.data.field_card.card_id, message.data.field_card);
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
    get fieldCards() {
      return fieldCards;
    },
  });

  return {
    set fieldId(value: FieldId | undefined) {
      fieldId = value;
    },
  };
}
