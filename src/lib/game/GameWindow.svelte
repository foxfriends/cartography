<script lang="ts">
  import { getGameState } from "./GameStateProvider.svelte";
  import CardField from "./CardField.svelte";
  import { CardPlacedEvent } from "$lib/events/CardPlacedEvent";
  import type { CardId } from "$lib/engine/Card";
  import { getAppState } from "./AppStateProvider.svelte";
  import CardFlow from "./CardFlow.svelte";
  import DragWindow from "$lib/components/DragWindow.svelte";
  import GridLines from "$lib/components/GridLines.svelte";

  const TILE_SIZE = 128;

  const appState = getAppState();
  const gameState = getGameState();
  const { geography, deck, field, flow } = $derived(gameState);

  let clientWidth = $state(0);
  let clientHeight = $state(0);
  let offsetX = $state(0);
  let offsetY = $state(0);

  function onMoveCard(id: CardId, movementX: number, movementY: number) {
    const card = field.find((card) => card.id === id);
    if (card) {
      const destinationX = card.loose
        ? Math.round((card.x + movementX) / TILE_SIZE)
        : card.x + Math.round(movementX / TILE_SIZE);
      const destinationY = card.loose
        ? Math.round((card.y + movementY) / TILE_SIZE)
        : card.y + Math.round(movementY / TILE_SIZE);
      if (field.some((card) => card.x === destinationX && card.y === destinationY)) return;
      card.x = destinationX;
      card.y = destinationY;
      card.loose = false;

      window.dispatchEvent(new CardPlacedEvent(card));
    }
  }

  const xMin = $derived(Math.floor(offsetX / TILE_SIZE));
  const yMin = $derived(Math.floor(offsetY / TILE_SIZE));
  const xMax = $derived(Math.floor((offsetX + clientWidth) / TILE_SIZE) + 1);
  const yMax = $derived(Math.floor((offsetY + clientHeight) / TILE_SIZE) + 1);

  function isOnScreen({ x, y }: { x: number; y: number }): boolean {
    if (clientWidth === 0 || clientHeight === 0) return false;
    return xMin <= x && x < xMax && yMin <= y && y < yMax;
  }

  const terrain = $derived(
    geography.terrain
      .slice(Math.max(0, yMin - geography.origin.y), Math.max(0, yMax - geography.origin.y))
      .flatMap((row, y) =>
        row
          .slice(Math.max(0, xMin - geography.origin.x), Math.max(0, xMax - geography.origin.x))
          .map((col, x) => ({
            x: x + Math.max(xMin - geography.origin.x, 0),
            y: y + Math.max(yMin - geography.origin.y, 0),
            ...col,
          })),
      ),
  );

  const visibleField = $derived(field.filter((card) => card.loose || isOnScreen(card)));
  const activeField = $derived(visibleField.filter((card) => !card.loose));
</script>

<DragWindow
  tileWidth={128}
  tileHeight={128}
  gridHeight={8}
  gridWidth={8}
  bind:offsetX
  bind:offsetY
  bind:clientWidth
  bind:clientHeight
>
  {#each terrain as tile (tile)}
    <div class="terrain" data-type={tile.type} style="--grid-x: {tile.x}; --grid-y: {tile.y}"></div>
  {/each}

  <GridLines />
  <CardField field={visibleField} {deck} {onMoveCard} />
  {#if appState.mode === "flow"}
    <CardFlow field={activeField} {deck} {flow} />
  {/if}
</DragWindow>

<style>
  .terrain {
    position: absolute;
    top: 0;
    left: 0;
    width: var(--card-size);
    height: var(--card-size);
    transform: translate(
      calc(var(--grid-x) * var(--card-size) - var(--offset-x)),
      calc(var(--grid-y) * var(--card-size) - var(--offset-y))
    );

    &[data-type="grass"] {
      background-color: rgb(63 155 11);
    }

    &[data-type="soil"] {
      background-color: rgb(87 54 8);
    }

    pointer-events: none;
  }
</style>
