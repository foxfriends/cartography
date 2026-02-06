

export const index = 0;
let component_cache;
export const component = async () => component_cache ??= (await import('../entries/pages/_layout.svelte.js')).default;
export const universal = {
  "ssr": false,
  "prerender": true
};
export const universal_id = "src/routes/+layout.ts";
export const imports = ["_app/immutable/nodes/0.Bpyn17vy.js","_app/immutable/chunks/DTjTDYf3.js","_app/immutable/chunks/Cy0nnqwK.js","_app/immutable/chunks/VCyrUZ76.js","_app/immutable/chunks/C3Bw9t1P.js"];
export const stylesheets = [];
export const fonts = [];
