import { getContext, setContext } from "svelte";
import { PUBLIC_SERVER_WS_URL } from "$env/static/public";
import { SocketV1 } from "./socket/SocketV1";

const SOCKET = Symbol("Socket");

export function getSocket(): SocketV1 {
  const context = getContext(SOCKET) as { get socket(): SocketV1 };
  return context.socket;
}

export function provideSocket() {
  let socket = $state();

  $effect.pre(() => {
    const newSocket = new SocketV1(`${PUBLIC_SERVER_WS_URL}/websocket`);

    newSocket.addEventListener("open", () => {
      newSocket.auth({ id: "foxfriends" });
    });

    socket = newSocket;

    return () => newSocket.close();
  });

  setContext(SOCKET, {
    get socket() {
      return socket;
    },
  });
}
