<script module lang="ts">
  import { getContext, setContext, type Snippet } from "svelte";
  import { PUBLIC_SERVER_WS_URL } from "$env/static/public";
  import { SocketV1 } from "./SocketV1";

  const SOCKET = Symbol("SOCKET");
  export function getSocket(): SocketV1 {
    return getContext(SOCKET) as SocketV1;
  }
</script>

<script lang="ts">
  const { children }: { children: Snippet } = $props();

  const socket = new SocketV1(`${PUBLIC_SERVER_WS_URL}/websocket`);

  socket.addEventListener("message", (event) => {
    // eslint-disable-next-line no-console
    console.log("Message received", event.message);
    if (event.message.type === "account") {
      socket.subscribe("fields");
    }
  });

  setContext(SOCKET, socket);
</script>

{@render children()}
