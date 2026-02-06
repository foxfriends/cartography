<script lang="ts">
  import { resolve } from "$app/paths";
</script>

<main>
  <h1>This game?</h1>
  <a href={resolve("/cards")}>See the cards</a>
  <a href={resolve("/play")}>Just Play</a>
  <a href={resolve("/demo")}>Try Demo</a>
</main>

<style>
  main {
    width: 100%;
    height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 1rem;
  }

  h1 {
    font-size: 2rem;
  }
</style>
