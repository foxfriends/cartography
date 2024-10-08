// See https://kit.svelte.dev/docs/types#app

import type { EventHandler } from "svelte/elements";
import type { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
import type { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
import type { CardPlacedEvent } from "$lib/events/CardPlacedEvent";
import type { DeckOpenedEvent } from "$lib/events/DeckOpenedEvent";
import type { CardFocusEvent } from "$lib/events/CardFocusEvent";
import type { ShopOpenedEvent } from "$lib/events/ShopOpenedEvent";
import type { BuyPackEvent } from "$lib/events/BuyPackEvent";
import type { StartFlowEvent } from "$lib/events/StartFlowEvent";
import type { CreateFlowEvent } from "$lib/events/CreateFlowEvent";
import type { DeleteFlowEvent } from "$lib/events/DeleteFlowEvent";

// for information about these interfaces
declare global {
  namespace App {
    // interface Error {}
    // interface Locals {}
    // interface PageData {}
    // interface Platform {}
  }

  declare namespace svelteHTML {
    // eslint-disable-next-line @typescript-eslint/naming-convention
    interface HTMLAttributes<T extends EventTarget> {
      oncardsreceived?: EventHandler<CardsReceivedEvent, T> | undefined | null;
      oncardfielded?: EventHandler<CardFieldedEvent, T> | undefined | null;
      oncardplaced?: EventHandler<CardPlacedEvent, T> | undefined | null;
      ondeckopened?: EventHandler<DeckOpenedEvent, T> | undefined | null;
      onshopopened?: EventHandler<ShopOpenedEvent, T> | undefined | null;
      oncardfocus?: EventHandler<CardFocusEvent, T> | undefined | null;
      onbuypack?: EventHandler<BuyPackEvent, T> | undefined | null;
      onstartflow?: EventHandler<StartFlowEvent, T> | undefined | null;
      oncreateflow?: EventHandler<CreateFlowEvent, T> | undefined | null;
      ondeleteflow?: EventHandler<DeleteFlowEvent, T> | undefined | null;
    }

    interface SvelteWindowAttributes {
      oncardsreceived?: EventHandler<CardsReceivedEvent, Window> | undefined | null;
      oncardfielded?: EventHandler<CardFieldedEvent, Window> | undefined | null;
      oncardplaced?: EventHandler<CardPlacedEvent, Window> | undefined | null;
      ondeckopened?: EventHandler<DeckOpenedEvent, Window> | undefined | null;
      onshopopened?: EventHandler<ShopOpenedEvent, Window> | undefined | null;
      oncardfocus?: EventHandler<CardFocusEvent, Window> | undefined | null;
      onbuypack?: EventHandler<BuyPackEvent, Window> | undefined | null;
      oncreateflow?: EventHandler<CreateFlowEvent, Window> | undefined | null;
      ondeleteflow?: EventHandler<DeleteFlowEvent, Window> | undefined | null;
    }
  }
}

export {};
