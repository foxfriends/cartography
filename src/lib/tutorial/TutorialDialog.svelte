<script lang="ts">
  import type { Snippet } from "svelte";

  const {
    onDismiss,
    children,
    actions,
  }: { onDismiss?: () => void; children: Snippet; actions: Snippet<[dismiss: () => void]> } =
    $props();

  let dialog: HTMLDialogElement | undefined = $state();

  export function show() {
    dialog?.showModal();
  }

  function dismiss() {
    dialog?.close();
    onDismiss?.();
  }
</script>

<!-- Step 2 -->
<dialog bind:this={dialog}>
  <article>
    {@render children()}
  </article>
  <div class="controls">
    {@render actions(dismiss)}
  </div>
</dialog>

<style>
  dialog[open] {
    display: flex;
    opacity: 1;
    transform: translate(-50%, -50%) scale(1);
  }

  dialog {
    padding: 1.5rem;
    position: fixed;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%) scale(0.75);
    max-width: 60ch;
    flex-direction: column;
    gap: 1rem;
    border: none;
    border-radius: 0.5rem;
    box-shadow: 0 0 4rem rgb(0 0 0 / 0.25);

    opacity: 0;

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

  article {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .controls {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
  }
</style>
