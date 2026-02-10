import { createContext } from "svelte";
import { PUBLIC_SERVER_WS_URL } from "$env/static/public";
import { SocketV1 } from "./socket/SocketV1.svelte";

interface SocketContext {
  get socket(): SocketV1;
}

const [getSocket, setSocket] = createContext<SocketContext>();

export { getSocket };

export function provideSocket() {
  const context = $state<{ socket: SocketV1 }>({ socket: undefined! });

  $effect.pre(() => {
    const socket = (context.socket = new SocketV1(`${PUBLIC_SERVER_WS_URL}/play/ws`));

    socket.addEventListener("open", () => {
      socket.auth({ id: "foxfriends" });
    });

    return () => socket.close();
  });

  setSocket(context);
}
