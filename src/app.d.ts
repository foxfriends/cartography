// See https://kit.svelte.dev/docs/types#app

import type { EventHandler } from "svelte/elements";
import type { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
import type { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
import type { CardPlacedEvent } from "$lib/events/CardPlacedEvent";
import type { DeckOpenedEvent } from "$lib/events/DeckOpenedEvent";
import type { CardFocusEvent } from "$lib/events/CardFocusEvent";

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
      oncardsreceived?: EventHandler<CardsReceivedEvent, T> | undefined | null;
      oncardfielded?: EventHandler<CardFieldedEvent, T> | undefined | null;
      oncardplaced?: EventHandler<CardPlacedEvent, T> | undefined | null;
      ondeckopened?: EventHandler<DeckOpenedEvent, T> | undefined | null;
      oncardfocus?: EventHandler<CardFocusEvent, T> | undefined | null;
    }

    interface SvelteWindowAttributes {
      oncardsreceived?: EventHandler<CardsReceivedEvent, Window> | undefined | null;
      oncardfielded?: EventHandler<CardFieldedEvent, Window> | undefined | null;
      oncardplaced?: EventHandler<CardPlacedEvent, Window> | undefined | null;
      ondeckopened?: EventHandler<DeckOpenedEvent, Window> | undefined | null;
      oncardfocus?: EventHandler<CardFocusEvent, Window> | undefined | null;
    }
  }
}

export {};
