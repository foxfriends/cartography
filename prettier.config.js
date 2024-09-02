export default {
  useTabs: false,
  singleQuote: false,
  trailingComma: "all",
  printWidth: 100,
  plugins: ["prettier-plugin-svelte"],
  overrides: [{ files: "*.svelte", options: { parser: "svelte" } }],
};
