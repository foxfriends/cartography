<script lang="ts">
  import { add } from "$lib/algorithm/reducer";
  import MoneyRef from "$lib/components/MoneyRef.svelte";
  import ResourceRef from "$lib/components/ResourceRef.svelte";
  import { resources, type ResourceType } from "$lib/data/resources";
  import type { ResourceProduction } from "$lib/game/ResourceStateProvider.svelte";

  const {
    resourceProduction,
  }: { resourceProduction: Partial<Record<ResourceType, ResourceProduction>> } = $props();

  const income = $derived(
    Object.entries(resourceProduction)
      .map(([resource, { produced, consumed, demand }]) => {
        const value = resources[resource as ResourceType].value;
        return (
          value * Math.max(0, produced - consumed - demand) +
          value * 10 * Math.min(demand, Math.max(0, produced - consumed))
        );
      })
      .reduce(add, 0),
  );
</script>

<table>
  <thead>
    <tr>
      <th>Resource</th>
      <th>Produced</th>
      <th>Consumed</th>
      <th>Satisfaction</th>
      <th>Exported</th>
      <th>Value</th>
      <th>Profit</th>
    </tr>
  </thead>
  <tbody>
    {#each Object.entries(resourceProduction) as [resourceType, production] (resourceType)}
      {@const excess = Math.max(0, production.produced - production.consumed - production.demand)}
      {@const satisfaction = Math.min(
        production.demand,
        Math.max(0, production.produced - production.consumed),
      )}
      {@const value = resources[resourceType as ResourceType].value}
      <tr>
        <th><ResourceRef id={resourceType as ResourceType} /></th>
        <td class="produced">{production.produced}</td>
        <td class="consumed">{production.consumed}</td>
        <td>
          <span class="produced">{satisfaction}</span> /
          <span class="consumed">{production.demand}</span>
        </td>
        <td class="consumed">{excess}</td>
        <td><MoneyRef amount={value} /></td>
        <td><MoneyRef amount={value * excess + value * 10 * satisfaction} /></td>
      </tr>
    {/each}
  </tbody>
  <tfoot>
    <tr>
      <th>Total</th>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td><MoneyRef amount={income} /></td>
    </tr>
  </tfoot>
</table>

<style>
  table {
    border-collapse: collapse;
    border: 1px solid rgb(0 0 0 / 0.12);
    font-weight: bold;
  }

  th:first-child {
    text-align: left;
  }

  thead {
    border-bottom: 1px solid rgb(0 0 0 / 0.12);
  }

  tfoot {
    border-top: 3px double rgb(0 0 0 / 0.12);
    font-size: 1.25rem;
  }

  td {
    text-align: right;
    font-variant-numeric: tabular-nums;
  }

  th,
  td {
    padding: 0.5rem 0.75rem;
  }

  :where(th, td):not(:first-child) {
    border-left: 1px solid rgb(0 0 0 / 0.12);
  }

  tr:nth-child(2n) {
    background-color: rgb(0 0 0 / 0.05);
  }

  .produced {
    color: oklch(from rgb(23 183 34) 0.65 c h);
  }

  .consumed {
    color: oklch(from rgb(213 61 28) 0.65 c h);
  }
</style>
