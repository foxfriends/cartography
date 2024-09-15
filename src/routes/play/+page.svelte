<script lang="ts">
  import GameProvider from "$lib/game/GameProvider.svelte";
  import GameWindow from "$lib/game/GameWindow.svelte";
  import Hud from "$lib/hud/Hud.svelte";
  import Tutorial from "$lib/tutorial/Tutorial.svelte";
</script>

<div role="application">
  <GameProvider>
    <main>
      <GameWindow />
    </main>
    <div class="hud">
      <Hud />
    </div>
    <Tutorial />
  </GameProvider>
</div>

<style>
  main,
  div {
    position: absolute;
    inset: 0;
    width: 100vw;
    height: 100vh;
  }

  .hud {
    pointer-events: none;
  }

  :global(html) {
    overscroll-behavior: none;
  }
</style>
