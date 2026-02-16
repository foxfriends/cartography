<script lang="ts">
  import type { FieldState } from "$lib/appserver/socket/SocketV1Protocol";
  import { getSocket } from "$lib/appserver/provideSocket.svelte";
  import DragTile from "$lib/components/DragTile.svelte";
  import DragWindow from "$lib/components/DragWindow.svelte";
  import GridLines from "$lib/components/GridLines.svelte";
  import FieldView from "./FieldView.svelte";
  import { createListFields } from "$lib/appserver/api";

  const { socket } = $derived.by(getSocket);

  const fields = createListFields(() => "foxfriends");

  let fieldId: number | undefined = $state();
  let fieldState: FieldState | undefined = $state();

  $effect(() => {
    if (fieldId) {
      socket.$watchField({ id: fieldId }, (state) => (fieldState = state));
    }
  });
</script>

<main class="void" role="application">
  <DragWindow>
    <GridLines />

    {#if fieldId === undefined}
      {#if fields.status === "error"}
        <div>{fields.error}</div>
      {:else if fields.status === "success"}
        {#each fields.data.data.fields as field, i (field.id)}
          <DragTile x={i} y={0} onClick={() => (fieldId = field.id)}>
            <div class="field-label">
              {#if field.name}
                {field.name}
              {:else}
                Field {field.id}
              {/if}
            </div>
          </DragTile>
        {:else}
          <div>No fields</div>
        {/each}
      {:else}
        <div>Loading</div>
      {/if}
    {:else if fieldState}
      <FieldView {fieldState} />
    {:else}
      <div>Loading</div>
    {/if}
  </DragWindow>
</main>

<style>
  main {
    position: absolute;
    inset: 0;
    width: 100vw;
    height: 100vh;
  }

  .void {
    background: black;
    --grid-lines-color: white;
    color: white;
  }

  .field-label {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-weight: 600;
    border: 1px solid rgb(0 0 0 / 0.12);
  }
</style>
