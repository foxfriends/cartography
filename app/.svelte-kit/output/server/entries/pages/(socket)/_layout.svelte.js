import "clsx";
import { p as provideSocket } from "../../../chunks/provideSocket.svelte.js";
function _layout($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    provideSocket();
    const { children } = $$props;
    children($$renderer2);
    $$renderer2.push(`<!---->`);
  });
}
export {
  _layout as default
};
