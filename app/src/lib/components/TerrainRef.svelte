<script lang="ts">
  import { terrains, type TerrainType } from "$lib/data/terrains";
  import Shimmer from "./Shimmer.svelte";

  const { id }: { id: TerrainType } = $props();
  const terrain = $derived(terrains[id]);
</script>

<Shimmer style="--shimmer-color: var(--color-terrain)">{terrain.name}</Shimmer>
