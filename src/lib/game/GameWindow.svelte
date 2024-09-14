<script lang="ts">
  import CardArea from "./CardArea.svelte";
  import GridLines from "./GridLines.svelte";

  const TILE_SIZE = 128;

  let clientWidth = $state(0);
  let clientHeight = $state(0);

  let offsetX = $state(0);
  let offsetY = $state(0);

  const geography: {
    biome: string;
    origin: { x: number; y: number };
    terrain: { type: string }[][];
    resources: { id: string; x: number; y: number }[];
  } = {
    biome: "Coast",
    origin: { x: 0, y: 0 },
    terrain: [
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Soil" },
        { type: "Soil" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Soil" },
        { type: "Soil" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
      [
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
        { type: "Grass" },
      ],
    ],
    resources: [],
  };

  const hand: { id: string; type: string }[] = [
    { id: "waterwell1", type: "water-well" },
    { id: "bakery1", type: "bakery" },
    { id: "wheatfarm1", type: "wheat-farm" },
    { id: "home1", type: "home" },
    { id: "home2", type: "home" },
  ];

  const cards: { id: string; x: number; y: number }[] = [
    { id: "waterwell1", x: 1, y: 1 },
    { id: "bakery1", x: 1, y: 2 },
    { id: "wheatfarm1", x: 2, y: 2 },
    { id: "home1", x: 3, y: 0 },
    { id: "home2", x: 2, y: 4 },
  ];

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
    const card = cards.find((card) => card.id === id);
    if (card) {
      const destinationX = card.x + Math.round(movementX / TILE_SIZE);
      const destinationY = card.y + Math.round(movementY / TILE_SIZE);
      if (cards.some((card) => card.x === destinationX && card.y === destinationY)) return;
      card.x = destinationX;
      card.y = destinationY;
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

  <CardArea cards={cards.filter(isOnScreen)} {hand} {onMoveCard} />
  <GridLines />
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

    &[data-type="Grass"] {
      background-color: rgb(63 155 11);
    }

    &[data-type="Soil"] {
      background-color: rgb(87 54 8);
    }

    pointer-events: none;
  }
</style>
