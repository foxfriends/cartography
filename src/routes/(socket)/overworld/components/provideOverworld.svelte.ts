import type { Field, FieldId } from "$lib/appserver/Field";
import { getSocket } from "$lib/appserver/provideSocket.svelte";
import { getContext, setContext } from "svelte";
import { SvelteMap } from "svelte/reactivity";

const OVERWORLD = Symbol("Overworld");

interface Overworld {
  get fields(): SvelteMap<FieldId, Field>;
}

export function getOverworld() {
  const overworld = getContext(OVERWORLD) as Overworld;
  return { ...overworld };
}

export function provideOverworld() {
  const socket = getSocket();

  let fields = new SvelteMap<FieldId, Field>();

  socket.$on("auth", () => {
    const subscription = socket.subscribe("fields");

    socket.getFields().$then(({ data }) => {
      fields = new SvelteMap(data.fields.map((field) => [field.id, field]));
    });

    subscription.$on("next", ({ message }) => {
      fields.set(message.data.field.id, message.data.field);
    });

    return () => {
      subscription.unsubscribe();
    };
  });

  setContext(OVERWORLD, {
    get fields() {
      return fields;
    },
  });
}
