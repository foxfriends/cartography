<script lang="ts">
  import { cards, type CardType } from "$lib/data/cards";

  let { id }: { id: CardType } = $props();
  let card = $derived(cards[id]);
</script>

<span class="card-reference">{card.name}</span>

<style>
  @property --gradient-offset {
    syntax: "<percentage>";
    inherits: false;
    initial-value: 0%;
  }

  .card-reference {
    font-weight: 600;

    color: transparent;
    background-image: linear-gradient(
      45deg,
      rgb(164 85 217) calc(0% - var(--gradient-offset)),
      rgb(222 27 193) calc(50% - var(--gradient-offset)),
      rgb(164 85 217) calc(100% - var(--gradient-offset)),
      rgb(222 27 193) calc(150% - var(--gradient-offset)),
      rgb(164 85 217) calc(200% - var(--gradient-offset))
    );
    background-repeat: repeat-x;
    background-clip: text;

    animation: card-name-pulse 4s linear infinite;
  }

  @keyframes card-name-pulse {
    from {
      --gradient-offset: 0%;
    }
    to {
      --gradient-offset: 100%;
    }
  }
</style>
