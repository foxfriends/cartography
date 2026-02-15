import { defineConfig } from "orval";

export default defineConfig({
  cartography: {
    output: {
      mode: "single",
      target: "src/lib/appserver/api.ts",
      schemas: "src/lib/appserver/dto",
      client: "svelte-query",
      baseUrl: process.env.PUBLIC_SERVER_URL,
      mock: false,
    },
    input: {
      target: "../openapi.json",
    },
  },
});
