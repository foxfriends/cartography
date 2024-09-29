<script lang="ts">
  import { fade } from "svelte/transition";
  import { CardFocusEvent } from "$lib/events/CardFocusEvent";
  import { cards, type CardType } from "$lib/data/cards";
  import { getAppState } from "./AppStateProvider.svelte";

  const {
    id,
    type: cardType,
    x,
    y,
    loose = false,
    onMove,
  }: {
    id: string;
    type: CardType;
    x: number;
    y: number;
    loose?: boolean;
    onMove: (deltaClientX: number, deltaClientY: number) => void;
  } = $props();

  const appState = getAppState();

  let mouseDragging = $state(false);
  let touchDragging: Touch | null = $state(null);
  let draggedX = $state(0);
  let draggedY = $state(0);
  let unmoved = $state(false);

  const looseRotation = Math.sign(Math.random() - 0.5) * (Math.round(Math.random() * 10) + 5);

  function onmousedown(event: MouseEvent) {
    if (event.buttons === 1) {
      unmoved = true;
      if (appState.mode === "place") {
        mouseDragging = true;
      }
    }
  }

  function onmouseup(event: MouseEvent) {
    if (event.button === 0 && mouseDragging) {
      mouseDragging = false;
      onMove(draggedX, draggedY);
      draggedX = 0;
      draggedY = 0;
    }
  }

  function onmousemove(event: MouseEvent) {
    if (!mouseDragging) return;
    unmoved = false;
    draggedX += event.movementX;
    draggedY += event.movementY;
  }

  function ontouchstart(event: TouchEvent) {
    if (touchDragging === null && event.changedTouches.length === 1) {
      touchDragging = event.changedTouches[0]!;
      unmoved = false;
    }
    event.stopPropagation();
  }

  function ontouchend(event: TouchEvent) {
    if (
      touchDragging &&
      !Array.from(event.touches).some((touch) => touch.identifier === touchDragging!.identifier)
    ) {
      touchDragging = null;
      onMove(draggedX, draggedY);
      draggedX = 0;
      draggedY = 0;
    }
  }

  function ontouchmove(event: TouchEvent) {
    if (touchDragging === null) return;
    unmoved = false;
    const previous = touchDragging;
    const current = Array.from(event.touches).find(
      (touch) => touch.identifier === previous.identifier,
    );
    if (!current) return;
    draggedX += current.clientX - previous.clientX;
    draggedY += current.clientY - previous.clientY;
    touchDragging = current;
  }

  function onclick() {
    if (unmoved) window.dispatchEvent(new CardFocusEvent(id));
  }

  const dragging = $derived(mouseDragging || touchDragging);
  const cardSymbol = $derived(
    cards[cardType].name
      .split(" ")
      .map((word) => word[0])
      .join(""),
  );
</script>

{#if dragging && !loose}
  <div
    class="griditem shadow"
    style="--grid-x: {x}; --grid-y: {y};"
    out:fade={{ duration: 50 }}
  ></div>
{/if}
<div
  class="griditem card"
  class:loose
  class:dragging
  aria-grabbed={!!dragging}
  style="
    --loose-x: {loose ? x : 0}px;
    --loose-y: {loose ? y : 0}px;
    --grid-x: {loose ? 0 : x};
    --grid-y: {loose ? 0 : y};
    --drag-x: {draggedX}px;
    --drag-y: {draggedY}px;
    --loose-rotation: {loose && !dragging ? looseRotation : 0}deg;
  "
  data-type={cardType}
  {onclick}
  {onmousedown}
  {ontouchstart}
  role="presentation"
>
  {cardSymbol}
</div>

<svelte:window {onmouseup} {onmousemove} {ontouchmove} {ontouchend} ontouchcancel={ontouchend} />

<style>
  .griditem {
    position: absolute;
    top: 0;
    left: 0;
    width: var(--card-size);
    height: var(--card-size);
    transform: translate(
        calc(
          var(--loose-x) + var(--grid-x) * var(--card-size) - var(--offset-x) + var(--drag-x, 0px)
        ),
        calc(
          var(--loose-y) + var(--grid-y) * var(--card-size) - var(--offset-y) + var(--drag-y, 0px)
        )
      )
      rotate(var(--loose-rotation));
  }

  .card {
    background-color: white;
    display: flex;
    border: 1px solid rgb(0 0 0 / 0.25);
    text-align: center;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 2rem;
    cursor: grab;
    transition:
      --grid-x 100ms,
      --grid-y 100ms,
      --loose-rotation 150ms,
      --loose-x 100ms,
      --loose-y 100ms;

    &:not(.dragging) {
      transition:
        --grid-x 100ms,
        --grid-y 100ms,
        --drag-x 100ms,
        --drag-y 100ms,
        --loose-rotation 150ms,
        --loose-x 100ms,
        --loose-y 100ms;
    }

    &:hover {
      box-shadow: 0 0 1rem rgb(0 0 0 /0.25);
      border: 1px solid rgb(91 200 227);
      z-index: 1;
    }
  }

  .shadow {
    background-color: rgb(0 0 0 / 0.15);
  }

  .loose {
    box-shadow: 0 0 2rem rgb(0 0 0 / 0.25);
  }
</style>
