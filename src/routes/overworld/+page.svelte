<script lang="ts">
  import { provideSocket } from "$lib/appserver/provideSocket.svelte";
  import { provideOverworld } from "./components/provideOverworld.svelte";

  provideSocket();
  provideOverworld();
</script>

<div role="application"></div>
