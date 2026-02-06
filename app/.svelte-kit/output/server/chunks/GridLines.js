import { Y as attr_class, _ as attr, Z as attr_style, $ as stringify } from "./index2.js";
function DragTile($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { x, y, loose = false, onClick, onMove, children } = $$props;
    let touchDragging = null;
    let draggedX = 0;
    let draggedY = 0;
    const looseRotation = Math.sign(Math.random() - 0.5) * (Math.round(Math.random() * 10) + 5);
    const dragging = touchDragging;
    {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> <div${attr_class("griditem tile svelte-1docm9i", void 0, {
      "loose": loose,
      "dragging": dragging,
      "clickable": !!onClick,
      "draggable": !!onMove
    })}${attr("aria-grabbed", false)}${attr_style(` --loose-x: ${stringify(loose ? x : 0)}px; --loose-y: ${stringify(loose ? y : 0)}px; --grid-x: ${stringify(loose ? 0 : x)}; --grid-y: ${stringify(loose ? 0 : y)}; --drag-x: ${stringify(draggedX)}px; --drag-y: ${stringify(draggedY)}px; --loose-rotation: ${stringify(loose && !dragging ? looseRotation : 0)}deg; `)} role="presentation">`);
    children?.($$renderer2);
    $$renderer2.push(`<!----></div>`);
  });
}
function GridLines($$renderer, $$props) {
  const { tileWidth, tileHeight } = $$props;
  $$renderer.push(`<div class="gridlines svelte-2yd5bj"${attr_style("", {
    "--tile-width": tileWidth !== void 0 ? `${tileWidth}px` : void 0,
    "--tile-height": tileHeight !== void 0 ? `${tileHeight}px` : void 0
  })}></div>`);
}
export {
  DragTile as D,
  GridLines as G
};
