<script lang="ts">
  import Shimmer from "./Shimmer.svelte";

  const { amount }: { amount?: number } = $props();
</script>

<Shimmer style="--shimmer-color: rgb(186 141 26)">
  {#if amount !== undefined}
    ${amount}
  {:else}
    Money
  {/if}
</Shimmer>
