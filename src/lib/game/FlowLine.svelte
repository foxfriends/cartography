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

  const id = $derived(`${x1}_${y1}_${x2}_${y2}`);
  const dx = $derived(x2 - x1);
  const dy = $derived(y2 - y1);
  const l = $derived(Math.sqrt(dx ** 2 + dy ** 2));
  const r = $derived(l / 2);
  const a = $derived(Math.atan2(dy, dx));

  const sx = $derived(Math.sign(dx));
  const sy = $derived(Math.sign(dy));

  const s = $derived(Math.sign(dx) || 1);
  const qx = $derived(x1 + dx / 2 + ((r * Math.sin(a)) / 2) * s);
  const qy = $derived(y1 + dy / 2 - ((r * Math.cos(a)) / 2) * s);
  const qx2 = $derived(x1 + dx / 2 + (((r + 12) * Math.sin(a)) / 2) * s);
  const qy2 = $derived(y1 + dy / 2 - (((r + 12) * Math.cos(a)) / 2) * s);

  const efficacy = $derived(
    1 - Math.max(0, Math.min(1, (l - TOP_RANGE) / (MAX_RANGE - TOP_RANGE)) * 0.75),
  );
</script>

<!-- svelte-ignore a11y_click_events_have_key_events -->
<path
  role="button"
  class:selectable={!!onclick}
  {onclick}
  tabindex="0"
  class="flow live"
  style="--efficacy: {efficacy}; fill: url(#{id}); stroke: url(#{id})"
  d="M {x1} {y1} Q {qx} {qy} {x2} {y2} Q {qx2} {qy2} {x1} {y1}"
/>

<defs>
  <linearGradient
    {id}
    x1={sx === -1 ? 1 : 0}
    y1={sy === -1 ? 1 : 0}
    x2={sx === -1 ? 0 : 1}
    y2={sy === -1 ? 0 : 1}
  >
    <stop
      offset="0%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 100%, var(--color-input) 0%)"
    />
    <stop
      offset="10%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 90%, var(--color-input) 10%)"
    />
    <stop
      offset="20%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 80%, var(--color-input) 20%)"
    />
    <stop
      offset="30%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 70%, var(--color-input) 30%)"
    />
    <stop
      offset="40%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 60%, var(--color-input) 40%)"
    />
    <stop
      offset="50%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 50%, var(--color-input) 50%)"
    />
    <stop
      offset="60%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 40%, var(--color-input) 60%)"
    />
    <stop
      offset="70%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 30%, var(--color-input) 70%)"
    />
    <stop
      offset="80%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 20%, var(--color-input) 80%)"
    />
    <stop
      offset="90%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 10%, var(--color-input) 90%)"
    />
    <stop
      offset="100%"
      style="stop-color: color-mix(in oklch shorter hue, var(--color-output) 0%, var(--color-input) 100%)"
    />
  </linearGradient>
</defs>

<style>
  .flow {
    stroke-width: 2;
    stroke-linecap: round;
    opacity: var(--efficacy);
  }

  .selectable {
    cursor: pointer;
    pointer-events: visiblePainted;
  }
</style>
