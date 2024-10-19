<script lang="ts">
  import { provideSocket } from "$lib/appserver/provideSocket.svelte";
  import { getOverworld, provideOverworld } from "./components/provideOverworld.svelte";

  provideSocket();
  provideOverworld();

  const { fields } = $derived.by(getOverworld());

  const extent = $derived(
    Array.from(fields.values())
      .map((field) => [field.grid_x, field.grid_y] as const)
      .reduce(
        ([xx, yy], [x, y]) =>
          [
            [Math.min(xx[0], x), Math.max(xx[1], x)],
            [Math.min(yy[0], y), Math.max(yy[1], y)],
          ] as const,
        [
          [Infinity, -Infinity],
          [Infinity, -Infinity],
        ] as const,
      ),
  );

  $inspect(extent);
</script>

<div role="application">
  <main class="void"></main>
</div>

<style>
  div,
  main {
    position: absolute;
    inset: 0;
    width: 100vw;
    height: 100vh;
  }

  .void {
    background: black;
  }
</style>
