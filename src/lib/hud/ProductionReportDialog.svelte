<script lang="ts">
  import Modal from "$lib/components/Modal.svelte";
  import ProductionReport from "./ProductionReport.svelte";
  import { getResourceState } from "$lib/game/ResourceStateProvider.svelte";

  const resourceState = getResourceState();
  const { resourceProduction } = $derived(resourceState);

  let dialog: Modal | undefined = $state();

  export function show() {
    dialog?.show();
  }

  export function close() {
    dialog?.close();
  }
</script>

<Modal bind:this={dialog}>
  <article>
    <header>
      <h1>Production Report</h1>
      <button class="close" onclick={() => dialog!.close()}>&times;</button>
    </header>
    <div class="content">
      <ProductionReport {resourceProduction} />
    </div>
  </article>
</Modal>

<style>
  .content {
    padding: 2rem;
    --card-grid-gap: 2rem;
  }

  header {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgb(0 0 0 / 0.12);
    padding: 2rem;
  }

  .close {
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid rgb(0 0 0 / 0.12);
    background: none;
    width: 2rem;
    aspect-ratio: 1 / 1;
    font-size: 1rem;
  }
</style>
