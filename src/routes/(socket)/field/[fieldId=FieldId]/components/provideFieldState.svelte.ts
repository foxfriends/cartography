import type { CardId } from "$lib/appserver/Card";
import type { Field, FieldId } from "$lib/appserver/Field";
import type { FieldCard } from "$lib/appserver/FieldCard";
import { getSocket } from "$lib/appserver/provideSocket.svelte";
import { getContext, setContext } from "svelte";
import { SvelteMap } from "svelte/reactivity";

const FIELD_STATE = Symbol("Field State");

interface FieldState {
  get field(): Field | undefined;
  get fieldCards(): FieldCard[];
}

export function getFieldState() {
  const state = getContext(FIELD_STATE) as FieldState;
  return () => ({ ...state });
}

export function provideFieldState(fieldId: FieldId, initial?: Field) {
  const socket = getSocket();

  let field: Field | undefined = $state(initial);
  let fieldCards = $state(new SvelteMap<CardId, FieldCard>());

  socket.$on("auth", () => {
    const fieldSubscription = socket.subscribe("fields");
    const fieldCardsSubscription = socket.subscribe({ topic: "field_cards", field_id: fieldId });

    socket.getField(fieldId).$then(({ data }) => {
      field = data.field;
      fieldCards = new SvelteMap(data.field_cards.map((card) => [card.card_id, card]));
    });

    fieldCardsSubscription.$on("next", ({ message }) => {
      fieldCards.set(message.data.field_card.card_id, message.data.field_card);
    });

    fieldSubscription.$on("next", ({ message }) => {
      field = message.data.field;
    });

    return () => {
      fieldSubscription.unsubscribe();
      fieldCardsSubscription.unsubscribe();
    };
  });

  setContext(FIELD_STATE, {
    get field() {
      return field;
    },
    get fieldCards() {
      return fieldCards;
    },
  });
}
