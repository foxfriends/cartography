<script lang="ts">
  import { cards } from "$lib/data/cards";

  const cardsOrdered = Object.values(cards).sort((a, b) => (a.type < b.type ? -1 : 1));
</script>

<div class="layout">
  <div class="controls">
    <a href="/" class="back-button">&larr; Back</a>
    <div class="fields">
      <input type="search" placeholder="Search..." />
    </div>
  </div>
  <div class="grid">
    {#each cardsOrdered as card}
      <div class="card">
        <div class="title">{card.name} | {card.category}</div>
        <div class="image"></div>
        <div class="info">This is a card description.</div>
      </div>
    {/each}
  </div>
</div>

<style>
  .layout {
    display: grid;
    grid-template-columns: auto 1fr;
    gap: 1rem;
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

  input {
    padding: 0.25rem;
    min-width: 32ch;
  }

  .grid {
    display: grid;
    grid-auto-flow: row;
    grid-template-columns: repeat(auto-fill, minmax(18rem, 1fr));
    grid-auto-rows: auto;
    gap: 1rem;
  }

  .card {
    width: 100%;
    aspect-ratio: 2.5 / 3.5;
    box-shadow: 0 0 1rem rgb(0 0 0 / 0.125);
    padding: 0.5rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;

    .title {
      padding: 0.125rem;
      border: 1px solid rgb(0 0 0 / 0.12);
    }

    .image {
      aspect-ratio: 1 / 1;
      width: 100%;
      background-color: rgb(0 0 0 / 0.1);
    }

    .info {
      border: 1px solid rgb(0 0 0 / 0.12);
      flex-grow: 1;
      padding: 0.125rem;
    }
  }
</style>
