import globals from "globals";
import eslint from "@eslint/js";
import tsEslint from "typescript-eslint";
import svelteEslint from "eslint-plugin-svelte";
import svelteParser from "svelte-eslint-parser";
import eslintConfigPrettier from "eslint-config-prettier";

export default tsEslint.config(
  eslint.configs.recommended,
  ...tsEslint.configs.recommended,
  ...svelteEslint.configs["flat/recommended"],
  eslintConfigPrettier,
  ...svelteEslint.configs["flat/prettier"],
  {
    rules: {
      "@typescript-eslint/no-unused-vars": [
        "warn",
        { varsIgnorePattern: "^_.*", argsIgnorePattern: "^_.*" },
      ],
    },
  },
  {
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: "module",
      globals: { ...globals.node, ...globals.browser },
      parser: svelteParser,
      parserOptions: {
        parser: tsEslint.parser,
        extraFileExtensions: [".svelte"],
      },
    },
  },
  {
    ignores: [
      "**/.DS_Store",
      "**/node_modules",
      "build",
      ".svelte-kit",
      "package",
      "**/.env",
      "**/.env.*",
      "!**/.env.example",
      "**/package-lock.json",
    ],
  },
);
