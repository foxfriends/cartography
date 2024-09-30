<script lang="ts">
  import type { MouseEventHandler } from "svelte/elements";

  const TILE_SIZE = 128;
  const TOP_RANGE = TILE_SIZE * 2;
  const MAX_RANGE = TILE_SIZE * 5;

  const {
    onclick,
    x1,
    y1,
    x2,
    y2,
  }: {
    x1: number;
    y1: number;
    x2: number;
    y2: number;
    onclick?: MouseEventHandler<SVGPathElement> | null | undefined;
  } = $props();

  const dx = $derived(x2 - x1);
  const dy = $derived(y2 - y1);
  const l = $derived(Math.sqrt(dx ** 2 + dy ** 2));
  const r = $derived(l / 2);
  const a = $derived(Math.atan2(dx, dy));
  const s = $derived(Math.sign(dx) || 1);
  const qx = $derived(x1 + dx / 2 + ((r * Math.cos(a)) / 2) * s);
  const qy = $derived(y1 + dy / 2 - ((r * Math.sin(a)) / 2) * s);
  const qx2 = $derived(x1 + dx / 2 + (((r + 12) * Math.cos(a)) / 2) * s);
  const qy2 = $derived(y1 + dy / 2 - (((r + 12) * Math.sin(a)) / 2) * s);
</script>

<!-- svelte-ignore a11y_click_events_have_key_events -->
<path
  role="button"
  class:selectable={!!onclick}
  {onclick}
  tabindex="0"
  class="flow live"
  style="--distance-loss: {Math.max(
    0,
    Math.min(1, (l - TOP_RANGE) / (MAX_RANGE - TOP_RANGE)) * 75,
  )}%"
  d="M {x1} {y1} Q {qx} {qy} {x2} {y2} Q {qx2} {qy2} {x1} {y1}"
/>

<style>
  .flow {
    fill: oklch(from var(--color-resource) l c h / calc(100% - var(--distance-loss)));
    stroke: oklch(from var(--color-resource) l c h / calc(100% - var(--distance-loss)));
    stroke-width: 2;
    stroke-linecap: round;
  }

  .selectable {
    cursor: pointer;
    pointer-events: visiblePainted;
  }
</style>
