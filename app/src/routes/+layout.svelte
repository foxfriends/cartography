<script lang="ts">
  import "core-js/actual/iterator";
  import * as Sentry from "@sentry/browser";
  import type { Snippet } from "svelte";
  import Package from "../../package.json";
  import { PUBLIC_SENTRY_DSN, PUBLIC_ENV } from "$env/static/public";
  import { QueryClient, QueryClientProvider } from "@sveltestack/svelte-query";

  if (PUBLIC_SENTRY_DSN) {
    Sentry.init({
      dsn: PUBLIC_SENTRY_DSN,
      release: Package.version,
      environment: PUBLIC_ENV,
    });
  }

  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, refetchInterval: false },
      mutations: { retry: false },
    },
  });

  const { children }: { children: Snippet } = $props();
</script>

<QueryClientProvider client={queryClient}>
  {@render children()}
</QueryClientProvider>
