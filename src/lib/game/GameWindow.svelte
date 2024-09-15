<script lang="ts">
  import { getGameState } from "./GameProvider.svelte";
  import CardField from "./CardField.svelte";
  import GridLines from "./GridLines.svelte";

  const TILE_SIZE = 128;

  let { geography, deck, field } = getGameState();

  let clientWidth = $state(0);
  let clientHeight = $state(0);

  let offsetX = $state(0);
  let offsetY = $state(0);

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
      touchDragging = event.changedTouches[0];
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

  function onMoveCard(id: string, movementX: number, movementY: number) {
    const card = field.find((card) => card.id === id);
    if (card) {
      const destinationX = card.loose
        ? Math.round((card.x + movementX) / TILE_SIZE)
        : card.x + Math.round(movementX / TILE_SIZE);
      const destinationY = card.loose
        ? Math.round((card.y + movementY) / TILE_SIZE)
        : card.y + Math.round(movementY / TILE_SIZE);
      if (field.some((card) => card.x === destinationX && card.y === destinationY)) return;
      card.x = destinationX;
      card.y = destinationY;
      card.loose = false;
    }
  }

  const xMin = $derived(Math.floor(offsetX / TILE_SIZE));
  const yMin = $derived(Math.floor(offsetY / TILE_SIZE));
  const xMax = $derived(Math.floor((offsetX + clientWidth) / TILE_SIZE) + 1);
  const yMax = $derived(Math.floor((offsetY + clientHeight) / TILE_SIZE) + 1);

  function isOnScreen({ x, y }: { x: number; y: number }): boolean {
    if (clientWidth === 0 || clientHeight === 0) return false;
    return xMin <= x && x < xMax && yMin <= y && y < yMax;
  }

  const terrain = $derived(
    geography.terrain
      .slice(Math.max(0, yMin - geography.origin.y), Math.max(0, yMax - geography.origin.y))
      .flatMap((row, y) =>
        row
          .slice(Math.max(0, xMin - geography.origin.x), Math.max(0, xMax - geography.origin.x))
          .map((col, x) => ({
            x: x + Math.max(xMin - geography.origin.x, 0),
            y: y + Math.max(yMin - geography.origin.y, 0),
            ...col,
          })),
      ),
  );
</script>

<div
  class="window"
  bind:clientWidth
  bind:clientHeight
  style="--offset-x: {offsetX}px; --offset-y: {offsetY}px"
  {onmousedown}
  {ontouchstart}
  {oncontextmenu}
  role="presentation"
>
  {#each terrain as tile (tile)}
    <div class="terrain" data-type={tile.type} style="--grid-x: {tile.x}; --grid-y: {tile.y}"></div>
  {/each}
  <GridLines />
  <CardField field={field.filter((card) => card.loose || isOnScreen(card))} {deck} {onMoveCard} />
</div>

<svelte:window {onmousemove} {onmouseup} {ontouchmove} {ontouchend} ontouchcancel={ontouchend} />

<style>
  .window {
    width: 100%;
    height: 100%;
    position: relative;
    overflow: hidden;
    background-color: rgb(255 255 255);
    user-select: none;
    isolation: isolate;
  }

  .terrain {
    position: absolute;
    top: 0;
    left: 0;
    width: var(--card-size);
    height: var(--card-size);
    transform: translate(
      calc(var(--grid-x) * var(--card-size) - var(--offset-x)),
      calc(var(--grid-y) * var(--card-size) - var(--offset-y))
    );

    &[data-type="grass"] {
      background-color: rgb(63 155 11);
    }

    &[data-type="soil"] {
      background-color: rgb(87 54 8);
    }

    pointer-events: none;
  }
</style>
