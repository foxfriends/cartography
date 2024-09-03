<script lang="ts">
  let clientWidth = $state(0);
  let clientHeight = $state(0);

  let offsetX = $state(0);
  let offsetY = $state(0);

  const cards: { id: string; x: number; y: number }[] = [
    { id: "test-card", x: 0, y: 0 },
    { id: "test-card-2", x: 3, y: 2 },
  ];

  let dragging = $state(false);

  function onmousedown(event: MouseEvent) {
    if (event.button === 0) {
      dragging = true;
    }
  }

  function onmouseup(event: MouseEvent) {
    if (event.button === 0) {
      dragging = false;
    }
  }

  function onmousemove(event: MouseEvent) {
    if (!dragging) return;
    offsetX -= event.movementX;
    offsetY -= event.movementY;
  }

  function onScreen({ x, y }: { x: number; y: number }): boolean {
    if (clientWidth === 0 || clientHeight === 0) return false;
    const xMin = Math.floor(offsetX / 128);
    const yMin = Math.floor(offsetY / 128);
    const xMax = Math.floor((offsetX + clientWidth) / 128);
    const yMax = Math.floor((offsetY + clientHeight) / 128);
    return xMin <= x && x <= xMax && yMin <= y && y <= yMax;
  }
</script>

<div
  class="window"
  bind:clientWidth
  bind:clientHeight
  style="--offset-x: {offsetX}px; --offset-y: {offsetY}px"
  {onmousedown}
  role="presentation"
>
  {#each cards.filter(onScreen) as card (card.id)}
    <div class="card" style="--grid-x: {card.x}; --grid-y: {card.y}"></div>
  {/each}

  <div class="gridlines"></div>
</div>

<svelte:window {onmousemove} {onmouseup} />

<style>
  .window {
    width: 100%;
    height: 100%;
    position: relative;
    overflow: hidden;
    background-color: rgb(63 155 11);
  }

  .card {
    position: absolute;
    top: 0;
    left: 0;
    width: var(--card-size);
    height: var(--card-size);
    transform: translate(
      calc(var(--grid-x) * var(--card-size) - var(--offset-x)),
      calc(var(--grid-y) * var(--card-size) - var(--offset-y))
    );
    background-color: white;
  }

  .gridlines {
    pointer-events: none;

    position: absolute;
    top: calc(0px - var(--card-size));
    left: calc(0px - var(--card-size));
    width: calc(100% + var(--card-size));
    height: calc(100% + var(--card-size));

    image-rendering: crisp-edges;

    background-position: mod(0px - var(--offset-x), var(--card-size))
      mod(0px - var(--offset-y), var(--card-size));
    background-repeat: repeat;
    background-size: var(--card-size) var(--card-size);
    background-image: linear-gradient(
        rgb(0 0 0 / 12%),
        rgb(0 0 0 / 12%) 1px,
        transparent 1px,
        transparent
      ),
      linear-gradient(
        to right,
        rgb(0 0 0 / 12%),
        rgb(0 0 0 / 12%) 1px,
        transparent 1px,
        transparent
      );
  }
</style>
