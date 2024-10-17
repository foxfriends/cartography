<script module lang="ts">
  import { getContext, setContext, type Snippet } from "svelte";
  import { PUBLIC_SERVER_WS_URL } from "$env/static/public";
  import { SocketV1 } from "./socket/SocketV1";

  const SOCKET = Symbol("SOCKET");
  export function getSocket(): SocketV1 {
    return getContext(SOCKET) as SocketV1;
  }
</script>

<script lang="ts">
  const { children }: { children: Snippet } = $props();

  const socket = new SocketV1(`${PUBLIC_SERVER_WS_URL}/websocket`);

  socket.addEventListener("open", async () => {
    await socket.auth({ id: "foxfriends" }).reply();

    socket.subscribe("fields").addEventListener("message", (_event) => {});
  });

  setContext(SOCKET, socket);
</script>

{@render children()}
