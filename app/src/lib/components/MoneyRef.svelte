<script lang="ts">
  import Shimmer from "./Shimmer.svelte";

  const { amount }: { amount?: number } = $props();
</script>

<Shimmer style="--shimmer-color: oklch(from var(--color-money) calc(l - 0.2) c h)">
  {#if amount !== undefined}
    ${amount}
  {:else}
    Money
  {/if}
</Shimmer>
