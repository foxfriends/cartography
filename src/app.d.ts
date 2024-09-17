// See https://kit.svelte.dev/docs/types#app

import type { EventHandler } from "svelte/elements";
import type { TutorialNotificationEvent } from "$lib/tutorial/Tutorial.svelte";
import type { CardReceivedEvent } from "$lib/events/CardReceivedEvent";
import type { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
import type { CardPlacedEvent } from "$lib/events/CardPlacedEvent";
import type { DeckOpenedEvent } from "$lib/events/DeckOpenedEvent";

// for information about these interfaces
declare global {
  namespace App {
    // interface Error {}
    // interface Locals {}
    // interface PageData {}
    // interface Platform {}
  }

  declare namespace svelteHTML {
    interface HTMLAttributes<T extends EventTarget> {
      oncardreceived?: EventHandler<CardReceivedEvent, T> | undefined | null;
      oncardfielded?: EventHandler<CardFieldedEvent, T> | undefined | null;
      oncardplaced?: EventHandler<CardPlacedEvent, T> | undefined | null;
      ondeckopened?: EventHandler<DeckOpenedEvent, T> | undefined | null;
    }

    interface SvelteWindowAttributes {
      oncardreceived?: EventHandler<CardReceivedEvent, Window> | undefined | null;
      oncardfielded?: EventHandler<CardFieldedEvent, Window> | undefined | null;
      oncardplaced?: EventHandler<CardPlacedEvent, Window> | undefined | null;
      ondeckopened?: EventHandler<DeckOpenedEvent, Window> | undefined | null;
    }
  }
}

export {};
