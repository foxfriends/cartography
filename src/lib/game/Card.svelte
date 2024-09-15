<script lang="ts">
  import { fade } from "svelte/transition";
  let {
    type: cardType,
    x,
    y,
    loose = false,
    onMove,
  }: {
    type: string;
    x: number;
    y: number;
    loose?: boolean;
    onMove: (deltaClientX: number, deltaClientY: number) => void;
  } = $props();

  let mouseDragging = $state(false);
  let touchDragging: Touch | null = $state(null);
  let draggedX = $state(0);
  let draggedY = $state(0);

  const looseRotation = Math.sign(Math.random() - 0.5) * (Math.round(Math.random() * 10) + 5);

  function onmousedown(event: MouseEvent) {
    if (event.buttons === 1) mouseDragging = true;
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
      touchDragging = null;
      onMove(draggedX, draggedY);
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

  const dragging = $derived(mouseDragging || touchDragging);
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
  {onmousedown}
  {ontouchstart}
  role="presentation"
>
  {cardType
    .split("-")
    .map((word) => word[0].toUpperCase())
    .join("")}
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
    border: 0.125rem solid rgb(0 0 0 / 0.25);
    display: flex;
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

    &.dragging {
      z-index: 1;
      box-shadow: 0 0 1rem rgb(0 0 0 / 0.25);
    }

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
  }

  .shadow {
    background-color: rgb(0 0 0 / 0.15);
  }

  .loose {
    box-shadow: 0 0 2rem rgb(0 0 0 / 0.25);
  }
</style>
