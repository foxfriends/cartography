<script lang="ts">
  import { FieldTile, GameState, TileId } from "$lib/appserver/socket/SocketV1Protocol";
  import DragTile from "$lib/components/DragTile.svelte";

  type RuntimeTile = FieldTile | { id: TileId; x: number | undefined; y: number | undefined };

  const { gameState }: { gameState: GameState } = $props();

  const uncommittedTiles: { id: TileId; x: number | undefined; y: number | undefined }[] = $state(
    [],
  );
  const fieldTiles = $derived<RuntimeTile[]>([...gameState.field.tiles, ...uncommittedTiles]);
</script>

{#each fieldTiles as fieldTile (fieldTile.id)}
  <DragTile
    x={fieldTile.x ?? 0}
    y={fieldTile.y ?? 0}
    loose={fieldTile.x === undefined || fieldTile.y === undefined}
  >
    {fieldTile.id}
  </DragTile>
{/each}
