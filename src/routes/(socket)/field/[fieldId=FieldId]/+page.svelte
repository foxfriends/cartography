<script lang="ts">
  import type { RouteParams } from "./$types";
  import { page } from "$app/stores";
  import { parseFieldId } from "$lib/appserver/Field";
  import DragWindow from "$lib/components/DragWindow.svelte";
  import { getFieldState, provideFieldState } from "./components/provideFieldState.svelte";

  const { fieldId } = $page.params as RouteParams;

  provideFieldState(parseFieldId(fieldId));

  const { field: _field, fieldCards: _fieldCards } = $derived.by(getFieldState);
</script>

<DragWindow></DragWindow>
