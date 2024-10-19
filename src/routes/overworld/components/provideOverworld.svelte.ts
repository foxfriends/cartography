import type { Field, FieldId } from "$lib/appserver/Field";
import { getSocket } from "$lib/appserver/provideSocket.svelte";
import type { Subscription } from "$lib/appserver/socket/Subscription";
import { getContext, setContext } from "svelte";
import { SvelteMap } from "svelte/reactivity";

const OVERWORLD = Symbol("Overworld");

interface Overworld {
  get fields(): SvelteMap<FieldId, Field>;
}

export function getOverworld() {
  return getContext(OVERWORLD) as Overworld;
}

export function provideOverworld() {
  const socket = getSocket();
  const fields = $state(new SvelteMap<FieldId, Field>());

  $effect(() => {
    let subscription: Subscription<"fields"> | undefined;
    socket.addEventListener("auth", () => {
      subscription?.unsubscribe();
      subscription = socket.subscribe("fields");
      subscription.addEventListener("next", ({ message }) => {
        fields.set(message.data.id, message.data);
      });
    });
    return () => subscription?.unsubscribe();
  });

  setContext(OVERWORLD, {
    get fields() {
      return fields;
    },
  });
}
