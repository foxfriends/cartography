<script lang="ts">
  import { species, type SpeciesType } from "$lib/data/species";
  import Shimmer from "./Shimmer.svelte";

  let { id, plural = false }: { id: SpeciesType; plural?: boolean } = $props();
  let specie = $derived(species[id]);
</script>

<Shimmer style="--shimmer-color: rgb(16 121 227)">
  {plural ? specie.namePlural : specie.name}
</Shimmer>
