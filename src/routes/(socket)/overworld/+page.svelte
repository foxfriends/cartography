<script lang="ts">
  import { resolve } from "$app/paths";
  import { goto } from "$app/navigation";
  import type { Field } from "$lib/appserver/Field";
  import DragTile from "$lib/components/DragTile.svelte";
  import DragWindow from "$lib/components/DragWindow.svelte";
  import GridLines from "$lib/components/GridLines.svelte";
  import { getOverworld, provideOverworld } from "./components/provideOverworld.svelte";

  provideOverworld();

  const { fields } = $derived.by(getOverworld);

  async function viewField(field: Field) {
    await goto(resolve(`/field/${field.id}`));
  }
</script>

<main class="void" role="application">
  <DragWindow>
    <GridLines />

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
