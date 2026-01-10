<script lang="ts">
  import { type Field } from "$lib/appserver/Field";
  import DragTile from "$lib/components/DragTile.svelte";
  import DragWindow from "$lib/components/DragWindow.svelte";
  import GridLines from "$lib/components/GridLines.svelte";
  import { getOverworldState, provideOverworldState } from "./components/provideOverworld.svelte";
  import { getFieldState, provideFieldState } from "./components/provideFieldState.svelte";

  provideOverworldState();
  const setFieldState = provideFieldState();

  const { fields } = $derived.by(getOverworldState);
  const { field, fieldCards } = $derived.by(getFieldState);

  async function viewField(field: Field) {
    setFieldState.fieldId = field.id;
  }
</script>

<main class="void" role="application">
  <DragWindow>
    <GridLines />

    {#if field}
      {#each fieldCards.values() as fieldCard (fieldCard.card_id)}
        <DragTile
          x={fieldCard.grid_x ?? 0}
          y={fieldCard.grid_y ?? 0}
          loose={fieldCard.grid_x === undefined || fieldCard.grid_y === undefined}
        >
          <div class="field-label">
            {#if field.name}
              {field.name}
            {:else}
              Field {field.id}
            {/if}
          </div>
        </DragTile>
      {/each}
    {:else}
      {#each fields.values() as field, i (field.id)}
        <DragTile x={i} y={0} onClick={() => viewField(field)}>
          <div class="field-label">
            {#if field.name}
              {field.name}
            {:else}
              Field {field.id}
            {/if}
          </div>
        </DragTile>
      {/each}
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
