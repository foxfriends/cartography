<script lang="ts">
  import { getGameState } from "$lib/game/GameProvider.svelte";
  import CardRef from "$lib/components/CardRef.svelte";
  import SpeciesRef from "$lib/components/SpeciesRef.svelte";
  import TutorialDialog from "./TutorialDialog.svelte";
  import ResourceRef from "$lib/components/ResourceRef.svelte";
  import TerrainRef from "$lib/components/TerrainRef.svelte";
  import { CardReceivedEvent } from "$lib/events/CardReceivedEvent";
  import type { DeckOpenedEvent } from "$lib/events/DeckOpenedEvent";
  import type { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
  import type { CardPlacedEvent } from "$lib/events/CardPlacedEvent";

  const { deck } = getGameState();

  let intro: TutorialDialog | undefined = $state();
  let placeNeighbourhood: TutorialDialog | undefined = $state();
  let deckView: TutorialDialog | undefined = $state();
  let arrangeNeighbourhood: TutorialDialog | undefined = $state();
  let aboutNeighbourhoods: TutorialDialog | undefined = $state();
  let aboutBakery: TutorialDialog | undefined = $state();
  let aboutSources: TutorialDialog | undefined = $state();

  type Step = "intro" | "place-neighbourhood" | "place-bakery" | "place-sources";

  let step: Step = $state("intro");

  $effect.pre(() => {
    const storedStep = window.localStorage.getItem("tutorial_step");
    if (!storedStep) return;
    const parsed = JSON.parse(storedStep);
    if (typeof parsed !== "string") return;
    step = parsed as Step;
  });

  $effect(() => {
    window.localStorage.setItem("tutorial_step", JSON.stringify(step));
    if (step === "intro") window.setTimeout(() => intro!.show(), 500);
  });

  function introReward() {
    step = "place-neighbourhood";

    window.setTimeout(
      () =>
        window.dispatchEvent(
          new CardReceivedEvent({
            id: window.crypto.randomUUID(),
            type: "cat-neighbourhood",
          }),
        ),
      500,
    );
  }

  function ondeckopened(_: DeckOpenedEvent) {
    if (step === "place-neighbourhood") {
      window.setTimeout(() => deckView!.show(), 100);
    }
  }

  function oncardfielded({ card }: CardFieldedEvent) {
    if (step === "place-neighbourhood" && card.type === "cat-neighbourhood") {
      window.setTimeout(() => arrangeNeighbourhood!.show(), 500);
    }
  }

  function oncardplaced({ card }: CardPlacedEvent) {
    if (
      step === "place-neighbourhood" &&
      deck.find((d) => d.id === card.id)?.type === "cat-neighbourhood"
    ) {
      window.setTimeout(() => aboutNeighbourhoods!.show(), 500);
      step = "place-bakery";
    }
    if (step === "place-bakery" && deck.find((d) => d.id === card.id)?.type === "bakery") {
      window.setTimeout(() => aboutBakery!.show(), 500);
      step = "place-sources";
    }
  }
</script>

<svelte:window {ondeckopened} {oncardfielded} {oncardplaced} />

<TutorialDialog
  bind:this={intro}
  onDismiss={() => window.setTimeout(() => placeNeighbourhood!.show(), 100)}
>
  <p>Hello Mayor! Welcome to the location of our new town!</p>
  <p>
    All of us are just getting started here ourselves. As you can see, we haven't even set up a
    single neighbourhood yet.
  </p>
  <p>Will you help us choose a spot for that right now?</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Of course!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={placeNeighbourhood} onDismiss={introReward}>
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
    Each <SpeciesRef id="cat" /> requires 1 <ResourceRef id="bread" /> per day to be satisfied. We can
    produce <ResourceRef id="bread" /> by building a <CardRef id="bakery" />.
  </p>
  <p class="info">Place a <CardRef id="bakery" /> from your deck into your town.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Got it!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutBakery}>
  <p>
    The <CardRef id="bakery" /> is a Production card. Production cards produce resources by consuming
    the resources of other cards nearby. To produce 5 units of <ResourceRef id="bread" />, the
    <CardRef id="bakery" /> uses 1 unit of <ResourceRef id="water" /> and 4 units of
    <ResourceRef id="flour" />.
  </p>
  <p>
    If we want this <CardRef id="bakery" /> working, we'll need to get our hands on those resources.
    Check your deck and see what else you can do.
  </p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>I'll take a look!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutSources}>
  <p>
    The <CardRef id="water-well" /> and <CardRef id="wheat-farm" /> cards are both Source cards, meaning
    they are able to produce resources without needing to consume anything first. Instead, they allow
    you to harvest resources straight from the source.
  </p>
  <p>
    While the <CardRef id="water-well" /> is able to produce water from anywhere, the
    <CardRef id="wheat-farm" /> requires being placed on fertile <TerrainRef id="soil" /> in order to
    grow wheat.
  </p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Makes sense to me!</button>
  {/snippet}
</TutorialDialog>

<style>
  .info {
    font-style: italic;
    font-weight: 600;
    color: rgb(0 0 0 / 0.4);
    font-size: 0.9rem;
  }
</style>
