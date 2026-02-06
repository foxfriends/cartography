export default {
  useTabs: false,
  singleQuote: false,
  trailingComma: "all",
  printWidth: 100,
  plugins: ["prettier-plugin-svelte", "prettier-plugin-sql"],
  overrides: [
    { files: "*.svelte", options: { parser: "svelte" } },
    { files: ".gmrc", options: { parser: "json" } },
    { files: "*.sql", options: { parser: "sql", language: "postgresql" } },
  ],
};
