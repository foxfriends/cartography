<script lang="ts">
  import type { Snippet } from "svelte";

  let {
    style,
    children,
  }: { style?: string | null | undefined; children?: Snippet | null | undefined } = $props();
</script>

<span {style} class="shimmer">{@render children?.()}</span>

<style>
  @property --shimmer-offset {
    syntax: "<percentage>";
    inherits: false;
    initial-value: 0%;
  }

  @property --shimmer-color {
    syntax: "<color>";
    inherits: false;
    initial-value: rgb(0 0 0);
  }

  .shimmer {
    font-weight: 600;

    color: transparent;
    background-image: linear-gradient(
      to right,
      var(--shimmer-color) calc(0% - var(--shimmer-offset)),
      oklch(from var(--shimmer-color) calc(l + 0.15) c calc(h + 15))
        calc(50% - var(--shimmer-offset)),
      var(--shimmer-color) calc(100% - var(--shimmer-offset)),
      oklch(from var(--shimmer-color) calc(l + 0.15) c calc(h + 15))
        calc(150% - var(--shimmer-offset)),
      var(--shimmer-color) calc(200% - var(--shimmer-offset))
    );
    background-repeat: repeat-x;
    background-clip: text;

    animation: shimmer 8s ease-in-out alternate infinite;
  }

  @keyframes shimmer {
    from {
      --shimmer-offset: 0%;
    }
    to {
      --shimmer-offset: 100%;
    }
  }
</style>
