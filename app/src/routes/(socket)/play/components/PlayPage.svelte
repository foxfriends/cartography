<script lang="ts">
  import { getSocket } from "$lib/appserver/provideSocket.svelte";
  import type { FieldId, GameState } from "$lib/appserver/socket/SocketV1Protocol";
  import DragTile from "$lib/components/DragTile.svelte";
  import DragWindow from "$lib/components/DragWindow.svelte";
  import GridLines from "$lib/components/GridLines.svelte";
  import FieldView from "./FieldView.svelte";

  const { socket } = $derived.by(getSocket);

  const fields = $derived(socket.listFields());

  let fieldId: FieldId | undefined = $state();
  let gameState: GameState | undefined = $state();

  $effect(() => {
    if (fieldId) {
      socket.$watchField({ id: fieldId }, (state) => (gameState = state));
    }
  });
</script>

<main class="void" role="application">
  <DragWindow>
    <GridLines />

    {#if fieldId === undefined}
      {#await fields}
        <div>Loading</div>
      {:then fields}
        {#each fields as field, i (field.id)}
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
      {:catch error}
        <div>{error}</div>
      {/await}
    {:else if gameState}
      <FieldView {gameState} />
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
