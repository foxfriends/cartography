import { U as store_get, V as unsubscribe_stores } from "../../../../../chunks/index2.js";
import { g as getContext, s as setContext } from "../../../../../chunks/context.js";
import "clsx";
import "@sveltejs/kit/internal";
import "../../../../../chunks/exports.js";
import "../../../../../chunks/utils.js";
import "@sveltejs/kit/internal/server";
import "../../../../../chunks/state.svelte.js";
import { D as DragWindow } from "../../../../../chunks/DragWindow.js";
import { g as getSocket } from "../../../../../chunks/provideSocket.svelte.js";
import { S as SvelteMap } from "../../../../../chunks/index-server.js";
const getStores = () => {
  const stores$1 = getContext("__svelte__");
  return {
    /** @type {typeof page} */
    page: {
      subscribe: stores$1.page.subscribe
    },
    /** @type {typeof navigating} */
    navigating: {
      subscribe: stores$1.navigating.subscribe
    },
    /** @type {typeof updated} */
    updated: stores$1.updated
  };
};
const page = {
  subscribe(fn) {
    const store = getStores().page;
    return store.subscribe(fn);
  }
};
function parseFieldId(string) {
  return Number.parseInt(string);
}
const FIELD_STATE = /* @__PURE__ */ Symbol("Field State");
function getFieldState() {
  const state = getContext(FIELD_STATE);
  return { ...state };
}
function provideFieldState(fieldId, initial) {
  const socket = getSocket();
  let field = initial;
  let fieldCards = new SvelteMap();
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
    }
  });
}
function _page($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    var $$store_subs;
    const { fieldId } = store_get($$store_subs ??= {}, "$page", page).params;
    provideFieldState(parseFieldId(fieldId));
    getFieldState();
    DragWindow($$renderer2, {});
    if ($$store_subs) unsubscribe_stores($$store_subs);
  });
}
export {
  _page as default
};
