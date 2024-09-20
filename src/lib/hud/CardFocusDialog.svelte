<script lang="ts">
  import Card from "$lib/components/Card.svelte";
  import type { Card as CardT } from "$lib/data/cards";
  import type { Snippet } from "svelte";

  let dialog: HTMLDialogElement | undefined = $state();
  let card: CardT | undefined = $state();

  export function show(cardToShow: CardT) {
    card = cardToShow;
    dialog?.show();
  }

  export function close() {
    dialog?.close();
  }
</script>

<dialog bind:this={dialog}>
  {#if card}
    <Card {card} />
  {/if}
</dialog>

<svelte:window onclick={close} />

<style>
  dialog {
    pointer-events: auto;
    position: fixed;
    left: unset;
    top: 4rem;
    right: 2rem;
    box-shadow: 0 0 2rem rgb(0 0 0 / 0.25);
    outline: none;
    border: none;
    width: 18rem;
  }
</style>
