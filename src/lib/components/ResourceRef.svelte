<script lang="ts">
  import type { Snippet } from "svelte";
  import Shimmer from "./Shimmer.svelte";

  let { children }: { children: Snippet } = $props();
</script>

<Shimmer style="--shimmer-color: rgb(227 73 52)">{@render children()}</Shimmer>
