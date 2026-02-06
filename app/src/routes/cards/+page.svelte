<script lang="ts">
  import { resolve } from "$app/paths";
  import { cards } from "$lib/data/cards";
  import CardGrid from "$lib/components/CardGrid.svelte";

  const cardsOrdered = Object.values(cards).sort((a, b) => (a.type < b.type ? -1 : 1));
</script>

<div class="layout">
  <div class="controls">
    <a href={resolve("/")} class="back-button">&larr; Back</a>
    <div class="fields">
      <input type="search" placeholder="Search..." />
    </div>
  </div>
  <div class="gridarea">
    <CardGrid cards={cardsOrdered} />
  </div>
</div>

<style>
  .layout {
    display: grid;
    grid-template-columns: auto 1fr;
    min-height: 100vh;
  }

  .controls,
  .fields {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .controls {
    border-right: 1px solid rgb(0 0 0 / 0.12);
  }

  .fields {
    padding-inline: 1rem;
  }

  .back-button {
    display: block;
    padding: 0.5rem 1rem;

    &:hover {
      background: rgb(0 0 0 / 0.1);
    }
  }

  .gridarea {
    padding: 1rem;
  }

  input {
    padding: 0.25rem;
    min-width: 32ch;
  }
</style>
