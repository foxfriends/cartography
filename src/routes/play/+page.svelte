<script lang="ts">
  import GameWindow from "$lib/game/GameWindow.svelte";
  import Hud from "$lib/hud/Hud.svelte";
</script>

<main>
  <GameWindow />
</main>
<div>
  <Hud />
</div>

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
