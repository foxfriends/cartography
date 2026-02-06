import "clsx";
import { s as setContext, g as getContext } from "./context.js";
const SOCKET = /* @__PURE__ */ Symbol("Socket");
function getSocket() {
  const context = getContext(SOCKET);
  return context.socket;
}
function provideSocket() {
  let socket;
  setContext(SOCKET, {
    get socket() {
      return socket;
    }
  });
}
export {
  getSocket as g,
  provideSocket as p
};
