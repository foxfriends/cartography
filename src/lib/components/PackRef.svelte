<script lang="ts">
  import type { Snippet } from "svelte";
  import Shimmer from "./Shimmer.svelte";

  const { children }: { children: Snippet } = $props();
</script>

<Shimmer style="--shimmer-color: var(--color-pack)">{@render children()}</Shimmer>
