<script lang="ts">
  import { provideSocket } from "$lib/appserver/provideSocket.svelte";
  import DragWindow from "$lib/components/DragWindow.svelte";
  import { getOverworld, provideOverworld } from "./components/provideOverworld.svelte";

  provideSocket();
  provideOverworld();

  const { fields } = $derived.by(getOverworld());

  const [extentX, extentY] = $derived(
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
</script>

<div role="application">
  <main class="void">
    <DragWindow
      tileWidth={128}
      tileHeight={128}
      gridHeight={extentY[1] - extentY[0]}
      gridWidth={extentX[1] - extentX[0]}
    >
      <!-- TODO -->
      <div></div>
    </DragWindow>
  </main>
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
