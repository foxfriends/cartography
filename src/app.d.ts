// See https://kit.svelte.dev/docs/types#app

import type { TutorialNotificationEvent } from "$lib/tutorial/Tutorial.svelte";
import type { EventHandler } from "svelte/elements";

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
      onnotifytutorial?: EventHandler<TutorialNotificationEvent, T> | undefined | null;
    }

    interface SvelteWindowAttributes {
      onnotifytutorial?: EventHandler<TutorialNotificationEvent, Window> | undefined | null;
    }
  }
}

export {};
