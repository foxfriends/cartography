

export const index = 3;
let component_cache;
export const component = async () => component_cache ??= (await import('../entries/pages/_page.svelte.js')).default;
export const imports = ["_app/immutable/nodes/3.rm3kMfwl.js","_app/immutable/chunks/DTjTDYf3.js","_app/immutable/chunks/Cy0nnqwK.js","_app/immutable/chunks/Dwwks_Q7.js"];
export const stylesheets = ["_app/immutable/assets/3.DHpgJXmb.css"];
export const fonts = [];
