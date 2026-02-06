import "clsx";
import "core-js/actual/iterator/index.js";
function _layout($$renderer, $$props) {
  const { children } = $$props;
  children($$renderer);
  $$renderer.push(`<!---->`);
}
export {
  _layout as default
};
