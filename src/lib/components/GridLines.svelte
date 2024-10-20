<script lang="ts">
  const { tileWidth, tileHeight }: { tileWidth?: number; tileHeight?: number } = $props();
</script>

<div
  class="gridlines"
  style:--tile-width={tileWidth !== undefined ? `${tileWidth}px` : undefined}
  style:--tile-height={tileHeight !== undefined ? `${tileHeight}px` : undefined}
></div>

<style>
  .gridlines {
    pointer-events: none;

    position: absolute;
    top: calc(0px - var(--tile-height));
    left: calc(0px - var(--tile-width));
    width: calc(100% + var(--tile-width));
    height: calc(100% + var(--tile-height));

    image-rendering: crisp-edges;

    background-position: mod(0px - var(--offset-x), var(--tile-width))
      mod(0px - var(--offset-y), var(--tile-height));
    background-repeat: repeat;
    background-size: var(--tile-width) var(--tile-height);
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
