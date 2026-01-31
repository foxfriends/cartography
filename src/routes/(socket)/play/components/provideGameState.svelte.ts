import type { GameState, FieldId } from "$lib/appserver/socket/SocketV1Protocol";
import { getSocket } from "$lib/appserver/provideSocket.svelte";
import jsonpatch from "json-patch";
import { getContext, setContext } from "svelte";

const GAME_STATE = Symbol("GameState");

export function getGameState(): { gameState: GameState } {
  const state = getContext(GAME_STATE) as { gameState: GameState };
  return { ...state };
}

export function provideGameState() {
  const socket = getSocket();

  let fieldId: FieldId | undefined = $state();
  let gameState: GameState | undefined = $state();

  socket.$on("auth", () => {
    $effect(() => {
      if (fieldId) {
        socket.$watchField({ id: fieldId });
        socket.$on("message", (event) => {
          if (event.message.response["#tag"] === "PutState") {
            gameState = event.message.response["#payload"];
          } else if (event.message.response["#tag"] === "PatchState") {
            const patches = event.message.response["#payload"];
            gameState = jsonpatch.apply(gameState, patches);
          }
        });
      }
    });
  });

  setContext(GAME_STATE, {
    get gameState() {
      return gameState;
    },
  });
}
