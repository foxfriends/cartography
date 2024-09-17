<script lang="ts">
  import { resources, type ResourceType } from "$lib/data/resources";
  import Shimmer from "./Shimmer.svelte";

  let { id }: { id: ResourceType } = $props();
  let resource = $derived(resources[id]);
</script>

<Shimmer style="--shimmer-color: rgb(227 73 52)">{resource.name}</Shimmer>
