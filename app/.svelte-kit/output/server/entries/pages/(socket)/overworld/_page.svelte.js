import { W as ensure_array_like } from "../../../../chunks/index2.js";
import { g as goto } from "../../../../chunks/client.js";
import { G as GridLines, D as DragTile } from "../../../../chunks/GridLines.js";
import { D as DragWindow } from "../../../../chunks/DragWindow.js";
import "clsx";
import { s as setContext, g as getContext } from "../../../../chunks/context.js";
import { g as getSocket } from "../../../../chunks/provideSocket.svelte.js";
import { S as SvelteMap } from "../../../../chunks/index-server.js";
import { e as escape_html } from "../../../../chunks/escaping.js";
const OVERWORLD = /* @__PURE__ */ Symbol("Overworld");
function getOverworld() {
  const overworld = getContext(OVERWORLD);
  return { ...overworld };
}
function provideOverworld() {
  const socket = getSocket();
  let fields = new SvelteMap();
  socket.$on("auth", () => {
    const subscription = socket.subscribe("fields");
    socket.getFields().$then(({ data }) => {
      fields = new SvelteMap(data.fields.map((field) => [field.id, field]));
    });
    subscription.$on("next", ({ message }) => {
      fields.set(message.data.field.id, message.data.field);
    });
    return () => {
      subscription.unsubscribe();
    };
  });
  setContext(OVERWORLD, {
    get fields() {
      return fields;
    }
  });
}
function _page($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    provideOverworld();
    const { fields } = getOverworld();
    async function viewField(field) {
      await goto(`/field/${field.id}`);
    }
    $$renderer2.push(`<main class="void svelte-urwvt6" role="application">`);
    DragWindow($$renderer2, {
      children: ($$renderer3) => {
        GridLines($$renderer3, {});
        $$renderer3.push(`<!----> <!--[-->`);
        const each_array = ensure_array_like(fields.values());
        for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
          let field = each_array[$$index];
          DragTile($$renderer3, {
            x: field.grid_x,
            y: field.grid_y,
            onClick: () => viewField(field),
            children: ($$renderer4) => {
              $$renderer4.push(`<div class="field-label svelte-urwvt6">`);
              if (field.name) {
                $$renderer4.push("<!--[-->");
                $$renderer4.push(`${escape_html(field.name)}`);
              } else {
                $$renderer4.push("<!--[!-->");
                $$renderer4.push(`Field ${escape_html(field.id)}`);
              }
              $$renderer4.push(`<!--]--></div>`);
            }
          });
        }
        $$renderer3.push(`<!--]-->`);
      },
      $$slots: { default: true }
    });
    $$renderer2.push(`<!----></main>`);
  });
}
export {
  _page as default
};
