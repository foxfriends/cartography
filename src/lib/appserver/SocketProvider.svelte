<script module lang="ts">
  import { getContext, setContext, type Snippet } from "svelte";
  import { PUBLIC_SERVER_WS_URL } from "$env/static/public";
  const SOCKET = Symbol("SOCKET");

  export function getSocket(): WebSocket {
    return getContext(SOCKET) as WebSocket;
  }
</script>

<script lang="ts">
  const { children }: { children: Snippet } = $props();

  const socket = new WebSocket(`${PUBLIC_SERVER_WS_URL}/websocket`, ["v1.cartography.app"]);

  setContext(SOCKET, socket);

  socket.addEventListener("open", () => {
    socket.send(JSON.stringify({ type: "auth", id: "foxfriends" }));
  });
</script>

{@render children()}
