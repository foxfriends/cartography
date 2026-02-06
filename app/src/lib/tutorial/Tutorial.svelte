<script lang="ts">
  import { getGameState } from "$lib/game/GameStateProvider.svelte";
  import { getResourceState } from "$lib/game/ResourceStateProvider.svelte";
  import CardRef from "$lib/components/CardRef.svelte";
  import SpeciesRef from "$lib/components/SpeciesRef.svelte";
  import TutorialDialog from "./TutorialDialog.svelte";
  import ResourceRef from "$lib/components/ResourceRef.svelte";
  import TerrainRef from "$lib/components/TerrainRef.svelte";
  import PackRef from "$lib/components/PackRef.svelte";
  import { CardsReceivedEvent } from "$lib/events/CardsReceivedEvent";
  import type { DeckOpenedEvent } from "$lib/events/DeckOpenedEvent";
  import type { CardFieldedEvent } from "$lib/events/CardFieldedEvent";
  import type { CardPlacedEvent } from "$lib/events/CardPlacedEvent";
  import { generateCardId } from "$lib/engine/Card";
  import MoneyRef from "$lib/components/MoneyRef.svelte";
  import type { BuyPackEvent } from "$lib/events/BuyPackEvent";

  const gameState = getGameState();
  const { deck, field, shop } = $derived(gameState);

  const resourceState = getResourceState();
  const { resourceProduction } = $derived(resourceState);

  type TutorialDialogComponent = ReturnType<typeof TutorialDialog>;

  let intro: TutorialDialogComponent | undefined = $state();
  let deckView: TutorialDialogComponent | undefined = $state();
  let arrangeNeighbourhood: TutorialDialogComponent | undefined = $state();
  let aboutNeighbourhoods: TutorialDialogComponent | undefined = $state();
  let aboutBakery: TutorialDialogComponent | undefined = $state();
  let aboutSources: TutorialDialogComponent | undefined = $state();
  let aboutTrade: TutorialDialogComponent | undefined = $state();
  let aboutIncome: TutorialDialogComponent | undefined = $state();
  let aboutPacks: TutorialDialogComponent | undefined = $state();
  let aboutShop: TutorialDialogComponent | undefined = $state();
  let aboutFlow: TutorialDialogComponent | undefined = $state();
  let complete: TutorialDialogComponent | undefined = $state();

  type Step =
    | "intro"
    | "place-neighbourhood"
    | "place-bakery"
    | "place-sources"
    | "await-production"
    | "place-trading-centre"
    | "buy-pack"
    | "produce-bread"
    | "complete";

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
    if (step === "buy-pack") window.setTimeout(() => aboutPacks!.show(), 500);
  });

  $effect(() => {
    if (step === "await-production") {
      if (resourceProduction.wheat && resourceProduction.wheat.produced > 0) {
        window.setTimeout(() => aboutTrade!.show(), 500);
      }
    }
  });

  $effect(() => {
    if (step === "produce-bread") {
      if (resourceProduction.bread && resourceProduction.bread.produced > 0) {
        window.setTimeout(() => complete!.show(), 500);
        step = "complete";
      }
    }
  });

  function introReward() {
    window.setTimeout(() => {
      window.dispatchEvent(
        new CardsReceivedEvent([{ id: generateCardId(), type: "cat-neighbourhood" }]),
      );
      step = "place-neighbourhood";
    }, 500);
  }

  function arrangeNeighbourhoodReward() {
    window.setTimeout(() => {
      window.dispatchEvent(new CardsReceivedEvent([{ id: generateCardId(), type: "bakery" }]));
      step = "place-bakery";
    }, 500);
  }

  function placeBakeryReward() {
    window.setTimeout(() => {
      window.dispatchEvent(
        new CardsReceivedEvent([
          { id: generateCardId(), type: "water-well" },
          { id: generateCardId(), type: "wheat-farm" },
        ]),
      );
      step = "place-sources";
    }, 500);
  }

  function aboutTradeReward() {
    window.setTimeout(() => {
      window.dispatchEvent(
        new CardsReceivedEvent([{ id: generateCardId(), type: "trading-centre" }]),
      );
      step = "place-trading-centre";
    }, 500);
  }

  function aboutIncomeReward() {
    gameState.money += 4;
    step = "buy-pack";
    shop.packs.push({
      id: window.crypto.randomUUID(),
      name: "Starter Pack?",
      description:
        "A one of a kind pack containing all you need to get started!\n" +
        "It looks like this one has been opened already, and some of the cards are missing.",
      price: 4,
      originalPrice: 20,
      contents: [
        { type: "card", card: "cat-neighbourhood", missing: true },
        { type: "card", card: "water-well", missing: true },
        { type: "card", card: "wheat-farm", missing: true },
        { type: "card", card: "flour-mill" },
        { type: "card", card: "bakery", missing: true },
      ],
    });
  }

  function ondeckopened(_: DeckOpenedEvent) {
    if (step === "place-neighbourhood") {
      window.setTimeout(() => deckView!.show(), 500);
    }
  }

  function onshopopened(_: DeckOpenedEvent) {
    if (step === "buy-pack") {
      window.setTimeout(() => aboutShop!.show(), 500);
    }
  }

  function oncardfielded({ card }: CardFieldedEvent) {
    if (step === "place-neighbourhood" && card.type === "cat-neighbourhood") {
      window.setTimeout(() => arrangeNeighbourhood!.show(), 500);
    }
  }

  function onbuypack(_event: BuyPackEvent) {
    if (step === "buy-pack") step = "produce-bread";
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
    }
    if (
      step === "place-sources" &&
      ["wheat-farm", "water-well"].every((cardtype) =>
        field.some((fc) => !fc.loose && deck.some((dc) => fc.id === dc.id && dc.type === cardtype)),
      )
    ) {
      window.setTimeout(() => aboutSources!.show(), 500);
    }
    if (
      step === "place-trading-centre" &&
      deck.find((d) => d.id === card.id)?.type === "trading-centre"
    ) {
      window.setTimeout(() => aboutIncome!.show(), 500);
    }
    if (step === "produce-bread" && deck.find((d) => d.id === card.id)?.type === "flour-mill") {
      window.setTimeout(() => aboutFlow!.show(), 500);
    }
  }
</script>

<svelte:window {ondeckopened} {onshopopened} {oncardfielded} {oncardplaced} {onbuypack} />

<TutorialDialog bind:this={intro} onDismiss={introReward}>
  <p>
    Hello mayor, and welcome to the location of our new town! All of us are just getting started
    here ourselves. We haven't even placed a single card yet!
  </p>
  <p>
    I have the card for a <CardRef id="cat-neighbourhood" /> right here, I'll put it into your deck. Since
    you're in charge here, I'll let you see about setting that up for us. Start by opening up the deck
    view.
  </p>
  <p class="info">The button to open the deck view is at the bottom right.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Of course!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={deckView}>
  <p>
    This is the deck view; the cards you see here are yours. There are all sorts of cards to be
    collected, each one providing a different function. I'm sure you'll soon have a whole collection
    and turn this town into a great place to live!
  </p>
  <p>
    For now, we just need to set up that <CardRef id="cat-neighbourhood" /> for your citizens to live
    in.
  </p>
  <p class="info">Click a card to drop it into the world.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Got it!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={arrangeNeighbourhood}>
  <p>
    The <CardRef id="cat-neighbourhood" /> is now on the field, but it's sitting loose. Make sure to properly
    set into the grid to ensure that it stays put.
  </p>
  <p class="info">Click and drag cards to relocate them.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>On it!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutNeighbourhoods} onDismiss={arrangeNeighbourhoodReward}>
  <p>
    Residential cards provide housing for residents in your town. The
    <CardRef id="cat-neighbourhood" /> in particular has room for 6 <SpeciesRef id="cat" /> residents.
  </p>
  <p>
    Each type of resident has different needs. When the needs of a resident are satisfied, their
    productivity increases and they will pay you more <MoneyRef />.
  </p>
  <p>
    A <SpeciesRef id="cat" /> requires 1 <ResourceRef id="bread" /> per day to be satisfied. Luckily,
    I have a <CardRef id="bakery" /> card already, which will allow us to produce that
    <ResourceRef id="bread" /> right here in town!
  </p>
  <p class="info">Place a <CardRef id="bakery" /> from your deck into your town.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Got it!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutBakery} onDismiss={placeBakeryReward}>
  <p>
    The <CardRef id="bakery" /> is a Production card. Production cards produce resources by consuming
    the resources of other cards nearby. To produce 5 units of <ResourceRef id="bread" />, the
    <CardRef id="bakery" /> uses 1 unit of <ResourceRef id="water" /> and 4 units of
    <ResourceRef id="flour" />.
  </p>
  <p>
    If we want this <CardRef id="bakery" /> working, we'll need to get our hands on those resources. I
    think I have a few more cards that might help with that, take a look and see what you can do.
  </p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Ok!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutSources} onDismiss={() => (step = "await-production")}>
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
  <p class="info">Make sure your new cards are both producing.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Makes sense to me!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutTrade} onDismiss={aboutTradeReward}>
  <p>
    The <CardRef id="wheat-farm" /> is producing, but without a <CardRef id="flour-mill" /> in town, there's
    nothing for us to do with the <ResourceRef id="wheat" />.
  </p>
  <p>
    Luckily, I've got one last card here with me, it's a rare <CardRef id="trading-centre" /> card. You'll
    probably never get your hands on another one of these. This <CardRef id="trading-centre" />
    will become the backbone of our town, allowing us to sell our excess resources in exchange for
    <MoneyRef />.
  </p>
  <p class="info">Place the <CardRef id="trading-centre" />.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Wow!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutIncome} onDismiss={aboutIncomeReward}>
  <p>
    This is a world of production and trade, so all resources are reported in a rate of
    <strong>production per day</strong>. Other than <MoneyRef />, there's not much point in
    stockpiling any resources. Instead, at the end of each day, any excess resources we haven't used
    get exported via the <CardRef id="trading-centre" />.
  </p>
  <p>
    The <CardRef id="wheat-farm" /> produces 4 <ResourceRef id="wheat" /> per day, but a unit of
    <ResourceRef id="wheat" /> is worth just <MoneyRef amount={1} /> when exported. The
    <ResourceRef id="water" /> on the other hand isn't even worth selling. Unused resources aren't worth
    much!
  </p>
  <p>
    Eventually most of your income will be coming from satisfied residents buying the things they
    need, but for now I'll just work out a deal real quick for your first export.
  </p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>I do like money...</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutPacks}>
  <p>
    The other thing the <CardRef id="trading-centre" /> allows you to trade for is more cards. For a little
    bit of <MoneyRef />, you can buy a pack containing a few common cards which you can add to your
    town.
  </p>
  <p class="info">Open up the shop with the button at the bottom right.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Exciting!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutShop}>
  <p>
    The shop offers new cards in <strong>Packs</strong>. The available packs are always changing,
    and each one contains a different assortment of cards, so be sure to check back often and buy
    any that catch your eye.
  </p>
  <p>
    There's one pack available right now, the <PackRef>Starter Pack</PackRef>, but I have a
    confession to make... I already opened it and gave you most of the cards. There's still one left
    though, I didn't want to take away all the fun!
  </p>
  <p class="info">Buy (the rest of) the <PackRef>Starter Pack</PackRef>.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>That's ok...</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={aboutFlow}>
  <p>
    There's just one last step: to set up the transportation of resources from where they are
    produced, to where they will be consumed. As the mayor, you're responsible for determining all
    of what goes where and how it gets there.
  </p>
  <p>
    In general, it's hard to move things long distances by hand in one day. One or two tiles is
    totally fine, but beyond that you'll be losing about 25% of the total throughput per tile. Any
    more than 5 tiles is too far for things to be carried by hand in a day at all, though you might
    be able find cards for useful tools to help with that type of thing later on.
  </p>
  <p class="info">Enter Flow mode and drag connections from producers to consumers.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Cool!</button>
  {/snippet}
</TutorialDialog>

<TutorialDialog bind:this={complete}>
  <p>
    That's it, the <CardRef id="bakery" /> is finally able to make its <ResourceRef id="bread" />!
    You don't have to set up connections for residents finding and consuming their needs, or for
    resources to be exported, that all happens automatically, so you'll find that already your
    expected profits for tomorrow are looking quite healthy!
  </p>
  <p>
    You'll be on your own from here on out. I look forward to seeing where you take the town, and
    meeting all the people who will eventually move in! Good luck, and I hope you have fun!
  </p>
  <p class="info">
    Cards don't only come from packs. Earn powerful and rare cards by participating in certain
    activities in the real world, or trade your cards online with other players to get exactly the
    ones you need.
  </p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>I will!</button>
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
