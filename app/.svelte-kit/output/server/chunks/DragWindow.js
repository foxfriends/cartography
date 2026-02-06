import { Z as attr_style, X as bind_props, $ as stringify } from "./index2.js";
function DragWindow($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    let {
      tileWidth = 128,
      tileHeight = 128,
      children,
      offsetX = 0,
      offsetY = 0,
      clientWidth = 0,
      clientHeight = 0
    } = $$props;
    $$renderer2.push(`<div class="window svelte-1j4berq"${attr_style(`--offset-x: ${stringify(offsetX)}px; --offset-y: ${stringify(offsetY)}px; --tile-width: ${stringify(tileWidth)}px; --tile-height: ${stringify(tileHeight)}px;`)} role="presentation">`);
    children?.($$renderer2);
    $$renderer2.push(`<!----></div>`);
    bind_props($$props, { offsetX, offsetY, clientWidth, clientHeight });
  });
}
export {
  DragWindow as D
};
