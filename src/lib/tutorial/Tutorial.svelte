<script lang="ts" module>
  export type TutorialNotification =
    | { type: "deck-opened" }
    | { type: "card-fielded"; card: Card }
    | { type: "card-placed"; card: FieldCard };

  export class TutorialNotificationEvent extends Event {
    detail: TutorialNotification;

    constructor(detail: TutorialNotification) {
      super("notifytutorial");
      this.detail = detail;
    }
  }
</script>

<script lang="ts">
  import type { Card } from "$lib/data/cards";
  import type { FieldCard } from "$lib/types";
  import CardRef from "$lib/components/CardRef.svelte";
  import SpeciesRef from "$lib/components/SpeciesRef.svelte";
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import TutorialDialog from "./TutorialDialog.svelte";
  import ResourceRef from "$lib/components/ResourceRef.svelte";

  const { deck } = getGameState();

  let intro: TutorialDialog | undefined = $state();
  let placeNeighbourhood: TutorialDialog | undefined = $state();
  let deckView: TutorialDialog | undefined = $state();
  let arrangeNeighbourhood: TutorialDialog | undefined = $state();
  let aboutNeighbourhoods: TutorialDialog | undefined = $state();
  let aboutBakery: TutorialDialog | undefined = $state();

  let step = $state(0);

  $effect.pre(() => {
    const storedStep = window.localStorage.getItem("tutorial_step");
    if (!storedStep) return;
    const parsed = JSON.parse(storedStep);
    if (typeof parsed !== "number") return;
    step = parsed;
  });

  $effect(() => {
    window.localStorage.setItem("tutorial_step", JSON.stringify(step));
    if (step === 0) {
      window.setTimeout(() => intro!.show(), 1000);
    } else if (step === 1) {
      window.setTimeout(() => placeNeighbourhood!.show(), 100);
    }
  });

  function nextStep() {
    step += 1;
  }

  function onnotifytutorial({ detail }: TutorialNotificationEvent) {
    console.log(step, detail);
    if (step === 2 && detail.type === "deck-opened") {
      window.setTimeout(() => deckView!.show(), 500);
    }
    if (step === 2 && detail.type === "card-fielded" && detail.card.type === "cat-neighbourhood") {
      window.setTimeout(() => arrangeNeighbourhood!.show(), 500);
    }
    if (
      step === 2 &&
      detail.type === "card-placed" &&
      deck.find((d) => d.id === detail.card.id)?.type === "cat-neighbourhood"
    ) {
      window.setTimeout(() => aboutNeighbourhoods!.show(), 500);
      step += 1;
    }
    if (
      step === 3 &&
      detail.type === "card-placed" &&
      deck.find((d) => d.id === detail.card.id)?.type === "bakery"
    ) {
      window.setTimeout(() => aboutBakery!.show(), 500);
      step += 1;
    }
  }
</script>

<svelte:window {onnotifytutorial} />

<TutorialDialog bind:this={intro} onDismiss={nextStep}>
  <p>Hello Mayor! Welcome to the location of your new town!</p>
  <p>
    We're actually... just getting started here ourselves. As you can see, we haven't even set up a
    single neighbourhood yet.
  </p>
  <p>Will you help us choose a spot for that right now?</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Of course!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={placeNeighbourhood} onDismiss={nextStep}>
  <p>
    Great! I have the card for a <CardRef id="cat-neighbourhood" /> right here, I'll put it into your
    deck. Take a look and see for yourself!
  </p>
  <p class="info">The button to open the deck is at the bottom right.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Ok, let me see...</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={deckView}>
  <p>This is the deck view; the cards you see here are yours!</p>
  <p>
    There are all sorts of cards to be collected, each one providing a different function. Be sure
    to collect as many as you can to grow your town into a vibrant place to live.
  </p>
  <p>
    We need to set up a neighbourhood for your citizens to live in, select your
    <CardRef id="cat-neighbourhood" /> now.
  </p>
  <p class="info">Click a card to drop it into the world.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Got it!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={arrangeNeighbourhood}>
  <p>
    The <CardRef id="cat-neighbourhood" /> is now on the field, but it's sitting loose. Make sure to
    properly set into the grid to ensure that it stays put.
  </p>
  <p class="info">Click and drag cards to relocate them.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>On it!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutNeighbourhoods}>
  <p>
    Residential cards provide housing for citizens in your town. The
    <CardRef id="cat-neighbourhood" /> in particular has room for 6 <SpeciesRef id="cat" /> residents.
  </p>
  <p>
    Each species of citizen has different needs. When the needs of a citizen are satisfied, their
    productivity increases and they will be willing to pay you more taxes.
  </p>
  <p>
    Each <SpeciesRef id="cat" /> requires 1 <ResourceRef>Bread</ResourceRef> per day to be satisfied.
    We can produce <ResourceRef>Bread</ResourceRef> by building a <CardRef id="bakery" />.
  </p>
  <p class="info">Place a <CardRef id="bakery" /> from your deck into your town.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Got it!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutBakery}>
  <p>
    The <CardRef id="bakery" /> is a Production card. Production cards produce resources by consuming
    the resources of other cards nearby. To produce 5 units of <ResourceRef>Bread</ResourceRef>, the
    <CardRef id="bakery" /> uses 1 unit of <ResourceRef>Water</ResourceRef> and 4 units of
    <ResourceRef>Flour</ResourceRef>.
  </p>
  <p>
    If we want this <CardRef id="bakery" /> working, we'll need to get our hands on those resources.
    Check your deck and see what else you can do.
  </p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Got it!</button>
  {/snippet}
</TutorialDialog>

<style>
  button {
    padding: 0.5rem 1rem;
    border: 1px solid rgb(0 0 0 / 0.25);
    border-radius: 0.25rem;
    background: rgb(0 0 0 / 0);
    cursor: pointer;

    &:hover,
    &:focus-visible {
      background-color: rgb(0 0 0 / 0.05);
    }
  }

  .info {
    font-style: italic;
    font-weight: 600;
    color: rgb(0 0 0 / 0.4);
    font-size: 0.9rem;
  }
</style>
