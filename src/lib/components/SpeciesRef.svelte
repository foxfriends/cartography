<script lang="ts">
  import { species, type SpeciesType } from "$lib/data/species";
  import Shimmer from "./Shimmer.svelte";

  const { id, plural = false }: { id: SpeciesType; plural?: boolean } = $props();
  const specie = $derived(species[id]);
</script>

<Shimmer style="--shimmer-color: var(--color-species)">
  {plural ? specie.namePlural : specie.name}
</Shimmer>
