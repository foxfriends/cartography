<script lang="ts">
  import "core-js/actual/iterator";
  import type { Snippet } from "svelte";

  const { children }: { children: Snippet } = $props();
</script>

{@render children()}
