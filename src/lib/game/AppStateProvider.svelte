<script module lang="ts">
  import { getContext, setContext, type Snippet } from "svelte";

  export type Mode = "place" | "flow";

  const APP_STATE = Symbol("APP_STATE");

  interface AppState {
    mode: Mode;
  }

  export function getAppState(): AppState {
    return getContext(APP_STATE) as AppState;
  }
</script>

<script lang="ts">
  const { children }: { children: Snippet } = $props();

  let mode: Mode = $state("place");

  setContext(APP_STATE, {
    get mode() {
      return mode;
    },
    set mode(newMode: Mode) {
      mode = newMode;
    },
  } satisfies AppState);
</script>

{@render children()}
