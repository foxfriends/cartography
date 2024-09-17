<script lang="ts">
  import { terrains, type TerrainType } from "$lib/data/terrains";
  import Shimmer from "./Shimmer.svelte";

  let { id }: { id: TerrainType } = $props();
  let terrain = $derived(terrains[id]);
</script>

<Shimmer style="--shimmer-color: rgb(38 163 38)">{terrain.name}</Shimmer>
