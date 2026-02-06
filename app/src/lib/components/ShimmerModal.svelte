<script lang="ts">
  import type { Snippet } from "svelte";

  const { children, style }: { style: string | null | undefined; children: Snippet } = $props();

  let dialog: HTMLDialogElement | undefined = $state();

  export function show() {
    dialog?.showModal();
  }

  export function close() {
    dialog?.close();
  }
</script>

<dialog bind:this={dialog} {style}>
  {@render children()}
</dialog>

<style>
  @property --pulse-distance {
    syntax: "<length>";
    inherits: false;
    initial-value: 0px;
  }

  @property --pulse-opacity {
    syntax: "<number>";
    inherits: false;
    initial-value: 1;
  }

  @property --pop-distance {
    syntax: "<length>";
    inherits: false;
    initial-value: 0px;
  }

  @property --pop-opacity {
    syntax: "<number>";
    inherits: false;
    initial-value: 1;
  }

  @property --shimmer-color {
    syntax: "<color>";
    inherits: false;
    initial-value: rgb(0 0 0);
  }

  dialog[open] {
    pointer-events: auto;
    opacity: 1;
    transform: translate(-50%, -50%) scale(1);
  }

  dialog {
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%) scale(0.75);
    border: none;
    box-shadow:
      0 0 2rem oklch(from var(--shimmer-color) l c h / 0.5),
      0 0 1px var(--pulse-distance)
        oklch(from var(--shimmer-color) calc(l + 0.05) calc(c + 0.05) h / var(--pulse-opacity)),
      0 0 1px var(--pop-distance) oklch(from var(--shimmer-color) l c h / var(--pop-opacity));
    opacity: 0;
    animation:
      1s ease-in-out 0s alternate-reverse infinite shimmer-pulse,
      2s ease-out 1.2s infinite shimmer-pop;

    transition:
      backdrop-filter 100ms ease-out,
      opacity 100ms ease-out,
      transform 100ms ease-out,
      display 100ms ease-out allow-discrete,
      overlay 100ms ease-out allow-discrete;
  }

  dialog::backdrop {
    background-color: rgb(0 0 0 / 0);
    backdrop-filter: blur(0px);

    transition:
      backdrop-filter 100ms,
      background-color 100ms,
      display 100ms allow-discrete,
      overlay 100ms allow-discrete;
  }

  dialog[open]::backdrop {
    background-color: rgb(0 0 0 / 0.25);
    backdrop-filter: blur(2px);
  }

  @starting-style {
    dialog[open] {
      opacity: 0;
      transform: translate(-50%, -50%) scale(0.75);
    }

    dialog[open]::backdrop {
      background-color: rgb(0 0 0 / 0);
      backdrop-filter: blur(0px);
    }
  }

  @keyframes shimmer-pulse {
    0% {
      --pulse-distance: 2rem;
      --pulse-opacity: 0.25;
    }
    100% {
      --pulse-distance: 4rem;
      --pulse-opacity: 0.35;
    }
  }

  @keyframes shimmer-pop {
    0% {
      --pop-distance: 0rem;
      --pop-opacity: 1;
    }
    10% {
      --pop-opacity: 1;
    }
    50% {
      --pop-distance: 3rem;
      --pop-opacity: 0;
    }
    100% {
      --pop-opacity: 0;
    }
  }
</style>
