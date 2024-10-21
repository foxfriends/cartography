<script lang="ts">
  import { provideSocket } from "$lib/appserver/provideSocket.svelte";
  import type { Snippet } from "svelte";

  provideSocket();

  const { children }: { children: Snippet } = $props();
</script>

{@render children()}
