// See https://kit.svelte.dev/docs/types#app

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
    interface SvelteWindowAttributes {
      ondeckopen?: EventHandler<CustomEvent<null>, Window>;
    }

    interface HTMLAttributes<T> {
      ondeckopen?: EventHandler<CustomEvent<null>, T>;
    }
  }
}

export {};
