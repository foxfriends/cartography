<script lang="ts">
  import { fade } from "svelte/transition";
  import type { Snippet } from "svelte";

  const {
    x,
    y,
    loose = false,
    onClick,
    onMove,
    children,
  }: {
    x: number;
    y: number;
    loose?: boolean;
    onMove?: (deltaClientX: number, deltaClientY: number) => void;
    onClick?: () => void;
    children?: Snippet;
  } = $props();

  let mouseDragging = $state(false);
  let touchDragging: Touch | null = $state(null);
  let draggedX = $state(0);
  let draggedY = $state(0);
  let unmoved = $state(false);

  const looseRotation = Math.sign(Math.random() - 0.5) * (Math.round(Math.random() * 10) + 5);

  function onmousedown(_event: MouseEvent) {
    unmoved = true;
    if (onMove) mouseDragging = true;
  }

  function onmouseup(event: MouseEvent) {
    if (event.button === 0 && mouseDragging) {
      mouseDragging = false;
      onMove?.(draggedX, draggedY);
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
      unmoved = false;
      if (onMove) touchDragging = event.changedTouches[0]!;
    }
    event.stopPropagation();
  }

  function ontouchend(event: TouchEvent) {
    if (
      touchDragging &&
      !Array.from(event.touches).some((touch) => touch.identifier === touchDragging!.identifier)
    ) {
      touchDragging = null;
      onMove?.(draggedX, draggedY);
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
    if (unmoved && onClick) onClick();
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
  class="griditem tile"
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
  {onclick}
  {onmousedown}
  {ontouchstart}
  role="presentation"
>
  {@render children?.()}
</div>

<svelte:window {onmouseup} {onmousemove} {ontouchmove} {ontouchend} ontouchcancel={ontouchend} />

<style>
  .griditem {
    position: absolute;
    top: 0;
    left: 0;
    width: var(--tile-width);
    height: var(--tile-height);
    transform: translate(
        calc(
          var(--loose-x) + var(--grid-x) * var(--tile-width) - var(--offset-x) + var(--drag-x, 0px)
        ),
        calc(
          var(--loose-y) + var(--grid-y) * var(--tile-height) - var(--offset-y) + var(--drag-y, 0px)
        )
      )
      rotate(var(--loose-rotation));
  }

  .tile {
    background-color: white;
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
