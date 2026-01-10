<script lang="ts">
  import AppStateProvider from "$lib/game/AppStateProvider.svelte";
  import GameStateProvider from "$lib/game/GameStateProvider.svelte";
  import ResourceStateProvider from "$lib/game/ResourceStateProvider.svelte";
  import GameWindow from "$lib/game/GameWindow.svelte";
  import Hud from "$lib/hud/Hud.svelte";
  import Tutorial from "$lib/tutorial/Tutorial.svelte";
</script>

<div role="application">
  <AppStateProvider>
    <GameStateProvider>
      <ResourceStateProvider>
        <main>
          <GameWindow />
        </main>
        <div class="hud">
          <Hud />
        </div>
        <Tutorial />
      </ResourceStateProvider>
    </GameStateProvider>
  </AppStateProvider>
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
