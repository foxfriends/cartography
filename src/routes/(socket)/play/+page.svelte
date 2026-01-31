<script lang="ts">
  import { getSocket } from "$lib/appserver/provideSocket.svelte";
  import PlayPage from "./components/PlayPage.svelte";

  const { socket } = $derived.by(getSocket);
</script>

{#if socket.account}
  {#key socket.account.id}
    <PlayPage />
  {/key}
{:else}
  <div>Logging in</div>
{/if}
