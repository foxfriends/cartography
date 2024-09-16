<script lang="ts">
  import { species, type SpeciesType } from "$lib/data/species";

  let { id, plural = false }: { id: SpeciesType; plural?: boolean } = $props();
  let specie = $derived(species[id]);
</script>

<span class="species-reference">{plural ? specie.namePlural : specie.name}</span>

<style>
  @property --gradient-offset {
    syntax: "<percentage>";
    inherits: false;
    initial-value: 0%;
  }

  .species-reference {
    font-weight: 600;

    color: transparent;
    background-image: linear-gradient(
      45deg,
      rgb(16 121 227) calc(0% - var(--gradient-offset)),
      rgb(38 59 153) calc(50% - var(--gradient-offset)),
      rgb(16 121 227) calc(100% - var(--gradient-offset)),
      rgb(38 59 153) calc(150% - var(--gradient-offset)),
      rgb(16 121 227) calc(200% - var(--gradient-offset))
    );
    background-repeat: repeat-x;
    background-clip: text;

    animation: species-name-pulse 4s linear infinite;
  }

  @keyframes species-name-pulse {
    from {
      --gradient-offset: 0%;
    }
    to {
      --gradient-offset: 100%;
    }
  }
</style>
