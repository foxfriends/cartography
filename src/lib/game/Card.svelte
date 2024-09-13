<script lang="ts">
  import { fade } from "svelte/transition";
  let {
    id,
    type: cardType,
    x,
    y,
    onMove,
  }: {
    id: string;
    type: string;
    x: number;
    y: number;
    onMove: (clientX: number, clientY: number) => void;
  } = $props();

  let mouseDragging = $state(false);
  let touchDragging: Touch | null = $state(null);
  let draggedX = $state(0);
  let draggedY = $state(0);

  function onmousedown(event: MouseEvent) {
    if (event.buttons === 1) mouseDragging = true;
  }

  function onmouseup(event: MouseEvent) {
    if (event.button === 0 && mouseDragging) {
      onMove(draggedX, draggedY);
      mouseDragging = false;
      draggedX = 0;
      draggedY = 0;
    }
  }

  function onmousemove(event: MouseEvent) {
    if (!mouseDragging) return;
    draggedX += event.movementX;
    draggedY += event.movementY;
  }

  function ontouchstart(event: TouchEvent) {
    if (touchDragging === null && event.changedTouches.length === 1) {
      touchDragging = event.changedTouches[0];
    }
    event.stopPropagation();
  }

  function ontouchend(event: TouchEvent) {
    if (
      touchDragging &&
      !Array.from(event.touches).some((touch) => touch.identifier === touchDragging!.identifier)
    ) {
      onMove(draggedX, draggedY);
      touchDragging = null;
      draggedX = 0;
      draggedY = 0;
    }
  }

  function ontouchmove(event: TouchEvent) {
    if (touchDragging === null) return;
    const previous = touchDragging;
    const current = Array.from(event.touches).find(
      (touch) => touch.identifier === previous.identifier,
    );
    if (!current) return;
    draggedX += current.clientX - previous.clientX;
    draggedY += current.clientY - previous.clientY;
    touchDragging = current;
  }
</script>

<div
  class="griditem card"
  class:dragging={mouseDragging || touchDragging}
  style="--grid-x: {x}; --grid-y: {y}; --drag-x: {draggedX}px; --drag-y: {draggedY}px"
  data-type={cardType}
  {onmousedown}
  {ontouchstart}
  role="presentation"
>
  {cardType
    .split("-")
    .map((word) => word[0].toUpperCase())
    .join("")}
</div>

{#if mouseDragging || touchDragging}
  <div
    class="griditem shadow"
    style="--grid-x: {x}; --grid-y: {y};"
    out:fade={{ duration: 50 }}
  ></div>
{/if}

<svelte:window {onmouseup} {onmousemove} {ontouchmove} {ontouchend} ontouchcancel={ontouchend} />

<style>
  .griditem {
    position: absolute;
    top: 0;
    left: 0;
    width: var(--card-size);
    height: var(--card-size);
    transform: translate(
      calc(var(--grid-x) * var(--card-size) - var(--offset-x) + var(--drag-x, 0px)),
      calc(var(--grid-y) * var(--card-size) - var(--offset-y) + var(--drag-y, 0px))
    );
  }

  .card {
    background-color: white;
    border: 0.125rem solid rgb(0 0 0 / 0.25);
    display: flex;
    text-align: center;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 2rem;
    cursor: grab;

    &.dragging {
      z-index: 1;
      box-shadow: 0 0 1rem rgb(0 0 0 / 0.25);
      transition-duration: 0;
    }

    &:not(.dragging) {
      transition: transform 0.1s;
    }
  }

  .shadow {
    background-color: rgb(0 0 0 / 0.15);
  }
</style>
