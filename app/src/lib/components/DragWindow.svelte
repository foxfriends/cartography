<script lang="ts">
  import type { Snippet } from "svelte";

  let {
    tileWidth = 128,
    tileHeight = 128,
    children,
    offsetX = $bindable(0),
    offsetY = $bindable(0),
    clientWidth = $bindable(0),
    clientHeight = $bindable(0),
  }: {
    tileWidth?: number;
    tileHeight?: number;
    offsetX?: number;
    offsetY?: number;
    clientWidth?: number;
    clientHeight?: number;
    children?: Snippet;
  } = $props();

  let mouseDragging = $state(false);

  function oncontextmenu(event: MouseEvent) {
    event.preventDefault();
  }

  function onmousedown(event: MouseEvent) {
    if (event.buttons === 2) mouseDragging = true;
  }

  function onmouseup(event: MouseEvent) {
    if (event.button === 2) mouseDragging = false;
  }

  function onmousemove(event: MouseEvent) {
    if (!mouseDragging) return;
    offsetX -= event.movementX;
    offsetY -= event.movementY;
  }

  let touchDragging: Touch | null = $state(null);

  function ontouchstart(event: TouchEvent) {
    if (touchDragging === null && event.changedTouches.length === 1) {
      touchDragging = event.changedTouches[0]!;
    }
  }

  function ontouchend(event: TouchEvent) {
    if (
      touchDragging &&
      !Array.from(event.touches).some((touch) => touch.identifier === touchDragging!.identifier)
    ) {
      touchDragging = null;
    }
  }

  function ontouchmove(event: TouchEvent) {
    if (touchDragging === null) return;
    const previous = touchDragging;
    const current = Array.from(event.touches).find(
      (touch) => touch.identifier === previous.identifier,
    );
    if (!current) return;
    offsetX -= current.clientX - previous.clientX;
    offsetY -= current.clientY - previous.clientY;
    touchDragging = current;
  }
</script>

<div
  class="window"
  bind:clientWidth
  bind:clientHeight
  style="--offset-x: {offsetX}px; --offset-y: {offsetY}px; --tile-width: {tileWidth}px; --tile-height: {tileHeight}px;"
  {onmousedown}
  {ontouchstart}
  {oncontextmenu}
  role="presentation"
>
  {@render children?.()}
</div>

<svelte:window {onmousemove} {onmouseup} {ontouchmove} {ontouchend} ontouchcancel={ontouchend} />

<style>
  @property --offset-x {
    syntax: "<length>";
    inherits: true;
    initial-value: 0;
  }

  @property --offset-y {
    syntax: "<length>";
    inherits: true;
    initial-value: 0;
  }

  @property --tile-width {
    syntax: "<length>";
    inherits: true;
    initial-value: 128px;
  }

  @property --tile-height {
    syntax: "<length>";
    inherits: true;
    initial-value: 128px;
  }

  .window {
    width: 100%;
    height: 100%;
    position: relative;
    overflow: hidden;
    user-select: none;
    isolation: isolate;
  }
</style>
