<script lang="ts">
  import type { Snippet } from "svelte";

  const { children, sizing = "fit" }: { children: Snippet; sizing?: "fit" | "fill" } = $props();

  let dialog: HTMLDialogElement | undefined = $state();

  export function show() {
    dialog?.showModal();
  }

  export function close() {
    dialog?.close();
  }
</script>

<dialog bind:this={dialog} class={sizing}>
  {@render children()}
</dialog>

<style>
  @property --modal-scale {
    syntax: "<number>";
    inherits: false;
    initial-value: 1;
  }

  dialog[open] {
    pointer-events: auto;
    opacity: 1;
    --modal-scale: 1;
  }

  dialog {
    position: absolute;
    transform: scale(0.75);
    border: none;
    box-shadow: 0 0 2rem rgb(0 0 0 / 0.25);
    opacity: 0;
    transform: scale(var(--modal-scale));
    --modal-scale: 0.75;

    &.fill {
      inset: 4rem;
      width: auto;
      height: auto;
    }

    &.fit {
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%) scale(var(--modal-scale));
    }

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
      --modal-scale: 0.75;
    }

    dialog[open]::backdrop {
      background-color: rgb(0 0 0 / 0);
      backdrop-filter: blur(0px);
    }
  }
</style>
