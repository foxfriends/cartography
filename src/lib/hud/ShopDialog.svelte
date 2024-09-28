<script lang="ts">
  import { getGameState } from "$lib/game/GameStateProvider.svelte";
  import Modal from "$lib/components/Modal.svelte";
  import { ShopOpenedEvent } from "$lib/events/ShopOpenedEvent";
  import type { Pack as PackT } from "$lib/engine/Pack";
  import Pack from "$lib/components/Pack.svelte";
  import Grid from "$lib/components/Grid.svelte";
  import { BuyPackEvent } from "$lib/events/BuyPackEvent";

  const gameState = getGameState();
  const { shop } = $derived(gameState);

  let dialog: Modal | undefined = $state();

  export function show() {
    dialog?.show();
    window.dispatchEvent(new ShopOpenedEvent());
  }

  function buyPack(pack: PackT) {
    dialog?.close();
    window.dispatchEvent(new BuyPackEvent(pack));
  }

  export function close() {
    dialog?.close();
  }
</script>

<Modal bind:this={dialog} sizing="fill">
  <article>
    <header>
      <h1>Shop</h1>
      <button class="close" onclick={() => dialog!.close()}>&times;</button>
    </header>
    <div class="content">
      <Grid items={shop.packs}>
        {#snippet item(pack)}
          <Pack {pack} onSelect={() => buyPack(pack)} />
        {/snippet}
      </Grid>
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
