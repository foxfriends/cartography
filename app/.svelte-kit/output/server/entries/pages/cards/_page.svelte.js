import "clsx";
import { c as cards, C as CardGrid } from "../../../chunks/CardGrid.js";
function _page($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const cardsOrdered = Object.values(cards).sort((a, b) => a.type < b.type ? -1 : 1);
    $$renderer2.push(`<div class="layout svelte-qmtet4"><div class="controls svelte-qmtet4"><a href="/" class="back-button svelte-qmtet4">← Back</a> <div class="fields svelte-qmtet4"><input type="search" placeholder="Search..." class="svelte-qmtet4"/></div></div> <div class="gridarea svelte-qmtet4">`);
    CardGrid($$renderer2, { cards: cardsOrdered });
    $$renderer2.push(`<!----></div></div>`);
  });
}
export {
  _page as default
};
