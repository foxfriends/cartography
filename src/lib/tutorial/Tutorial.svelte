<script lang="ts">
  import TutorialDialog from "./TutorialDialog.svelte";

  let intro: TutorialDialog | undefined = $state();
  let placeNeighbourhood: TutorialDialog | undefined = $state();

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
      step += 1;
    } else if (step === 2) {
      window.setTimeout(() => placeNeighbourhood!.show(), 100);
    }
  });

  function nextStep() {
    step += 1;
  }
</script>

<!-- Step 0 -->

<TutorialDialog bind:this={intro} onDismiss={nextStep}>
  <p>Hello Mayor! Welcome to the location of your new town!</p>
  <p>
    We're actually... just getting started here ourselves. As you can see, we haven't even set up a
    single neighbourhood yet.
  </p>
  <p>Will you help us choose a spot for that right now?</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Yeah I guess so...</button>
    <button onclick={dismiss}>Of course!</button>
  {/snippet}
</TutorialDialog>

<!-- Step 2 -->
<TutorialDialog bind:this={placeNeighbourhood} onDismiss={nextStep}>
  <p>Great! I have the card for a neighbourhood right here, I'll put it into your deck.</p>
  <p>
    Try opening up the deck and seeing it in there. I added a few other cards I had lying around as
    well, take a look!
  </p>
  <p class="info">The button to open the deck is at the bottom right.</p>

  {#snippet actions(dismiss)}
    <button onclick={dismiss}>Let me see...</button>
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
