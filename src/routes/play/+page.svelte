<script lang="ts">
  import GameProvider from "$lib/game/GameProvider.svelte";
  import GameWindow from "$lib/game/GameWindow.svelte";
  import Hud from "$lib/hud/Hud.svelte";
  import Tutorial from "$lib/tutorial/Tutorial.svelte";
</script>

<GameProvider>
  <main>
    <GameWindow />
  </main>
  <div>
    <Hud />
  </div>
  <Tutorial />
</GameProvider>

<style>
  main,
  div {
    position: absolute;
    inset: 0;
    width: 100vw;
    height: 100vh;
  }

  div {
    pointer-events: none;
  }

  :global(html) {
    overscroll-behavior: none;
  }
</style>
