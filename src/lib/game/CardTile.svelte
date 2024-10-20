<script lang="ts">
  import { CardFocusEvent } from "$lib/events/CardFocusEvent";
  import { cards, type CardType } from "$lib/data/cards";
  import { getAppState } from "./AppStateProvider.svelte";
  import type { CardId } from "$lib/engine/Card";
  import DragTile from "$lib/components/DragTile.svelte";

  const {
    id,
    type: cardType,
    x,
    y,
    loose = false,
    onMove,
  }: {
    id: CardId;
    type: CardType;
    x: number;
    y: number;
    loose?: boolean;
    onMove: (deltaClientX: number, deltaClientY: number) => void;
  } = $props();

  const appState = getAppState();

  function onclick() {
    window.dispatchEvent(new CardFocusEvent(id));
  }

  const cardSymbol = $derived(
    cards[cardType].name
      .split(" ")
      .map((word) => word[0])
      .join(""),
  );
</script>

<DragTile onMove={appState.mode === "place" ? onMove : undefined} onClick={onclick} {x} {y} {loose}>
  <div class="card">
    {cardSymbol}
  </div>
</DragTile>

<style>
  .card {
    width: 100%;
    height: 100%;
    display: flex;
    background-color: white;
    border: 1px solid rgb(0 0 0 / 0.25);
    text-align: center;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 2rem;
  }
</style>
