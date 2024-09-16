<script lang="ts">
  import type { Snippet } from "svelte";

  let { children }: { children: Snippet } = $props();
</script>

<span class="resource-reference">{@render children()}</span>

<style>
  @property --gradient-offset {
    syntax: "<percentage>";
    inherits: false;
    initial-value: 0%;
  }

  .resource-reference {
    font-weight: 600;

    color: transparent;
    background-image: linear-gradient(
      45deg,
      rgb(227 73 52) calc(0% - var(--gradient-offset)),
      rgb(217 133 85) calc(50% - var(--gradient-offset)),
      rgb(227 73 52) calc(100% - var(--gradient-offset)),
      rgb(217 133 85) calc(150% - var(--gradient-offset)),
      rgb(227 73 52) calc(200% - var(--gradient-offset))
    );
    background-repeat: repeat-x;
    background-clip: text;

    animation: resource-name-pulse 4s linear infinite;
  }

  @keyframes resource-name-pulse {
    from {
      --gradient-offset: 0%;
    }
    to {
      --gradient-offset: 100%;
    }
  }
</style>
