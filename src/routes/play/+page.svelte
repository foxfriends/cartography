<script lang="ts">
  import GameWindow from "$lib/game/GameWindow.svelte";
</script>

<main>
  <GameWindow />
</main>

<style>
  main {
    width: 100vw;
    height: 100vh;
  }

  :global(html) {
    overscroll-behavior: none;
  }
</style>
