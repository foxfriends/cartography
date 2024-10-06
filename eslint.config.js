import globals from "globals";
import eslint from "@eslint/js";
import tsEslint from "typescript-eslint";
import svelteEslint from "eslint-plugin-svelte";
import svelteParser from "svelte-eslint-parser";
import eslintConfigPrettier from "eslint-config-prettier";

export default tsEslint.config(
  eslint.configs.recommended,
  ...tsEslint.configs.strict,
  ...tsEslint.configs.stylistic,
  ...svelteEslint.configs["flat/recommended"],
  eslintConfigPrettier,
  ...svelteEslint.configs["flat/prettier"],
  {
    rules: {
      "no-console": "warn",
      "id-denylist": ["error", "idx"],
      "dot-notation": "error",
      "spaced-comment": "error",
      "prefer-template": "warn",
      "prefer-const": "warn",
      "no-var": "error",
      "no-useless-return": "error",
      "no-useless-rename": "error",
      "no-useless-computed-key": "error",
      "no-else-return": "error",
      "no-alert": "error",
      "no-lonely-if": "error",
      "no-nested-ternary": "error",
      "object-shorthand": "error",
      quotes: ["error", "double", { avoidEscape: true }],
      yoda: "error",
      eqeqeq: "error",
      "@typescript-eslint/no-non-null-assertion": "off",
      "@typescript-eslint/no-empty-function": "off",
      "@typescript-eslint/naming-convention": [
        "warn",
        {
          selector: "default",
          format: ["strictCamelCase"],
          leadingUnderscore: "allowSingleOrDouble",
        },
        {
          selector: "variable",
          modifiers: ["const", "global"],
          format: ["strictCamelCase", "UPPER_CASE"],
          leadingUnderscore: "allowSingleOrDouble",
        },
        {
          selector: "objectLiteralProperty",
          format: null,
        },
        {
          selector: "import",
          format: ["StrictPascalCase", "strictCamelCase"],
        },
        {
          selector: "enumMember",
          format: ["StrictPascalCase"],
        },
        {
          selector: "typeLike",
          format: ["StrictPascalCase"],
          leadingUnderscore: "allowSingleOrDouble",
        },
      ],
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
      "src-tauri/target",
      "vite.config.ts.timestamp-*",
    ],
  },
);
