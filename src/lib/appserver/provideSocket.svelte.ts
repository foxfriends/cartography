import { getContext, setContext } from "svelte";
import { PUBLIC_SERVER_WS_URL } from "$env/static/public";
import { SocketV1 } from "./socket/SocketV1";

const SOCKET = Symbol("Socket");

interface SocketContext {
  get socket(): SocketV1;
}

export function getSocket(): SocketV1 {
  const context = getContext(SOCKET) as SocketContext;
  return context.socket;
}

export function provideSocket() {
  let socket: SocketV1;

  $effect.pre(() => {
    socket = new SocketV1(`${PUBLIC_SERVER_WS_URL}/websocket`);

    socket.addEventListener("open", () => {
      socket.auth({ id: "foxfriends" });
    });

    return () => socket.close();
  });

  setContext(SOCKET, {
    get socket() {
      return socket;
    },
  } satisfies SocketContext);
}
