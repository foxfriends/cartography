<script lang="ts">
  let intro: HTMLDialogElement | undefined = $state();
  let placeNeighbourhood: HTMLDialogElement | undefined = $state();

  let step = $state(0);

  $inspect(step);

  $effect(() => {
    if (step === 0) {
      window.setTimeout(() => intro!.showModal(), 1000);
      step += 1;
    } else if (step === 2) {
      window.setTimeout(() => placeNeighbourhood!.showModal(), 100);
    }
  });

  function dismiss(event: MouseEvent & { currentTarget: HTMLButtonElement }) {
    event.currentTarget.closest("dialog")?.close();
    step += 1;
  }
</script>

<!-- Step 0 -->
<dialog bind:this={intro}>
  <article>
    <p>Hello Mayor! Welcome to the location of your new town!</p>
    <p>
      We're actually... just getting started here ourselves. As you can see, we haven't even set up
      a single neighbourhood yet.
    </p>
    <p>Will you help us choose a spot for that right now?</p>
  </article>
  <div class="controls">
    <button onclick={dismiss}>Yeah I guess so...</button>
    <button onclick={dismiss}>Of course!</button>
  </div>
</dialog>

<!-- Step 2 -->
<dialog bind:this={placeNeighbourhood}>
  <article>
    <p>Great! I have the card for a neighbourhood right here, I'll put it into your deck.</p>
    <p>
      Try opening up the deck and seeing it in there. I added a few other cards I had lying around
      as well, take a look!
    </p>
    <p class="info">The button to open the deck is at the bottom right.</p>
  </article>
  <div class="controls">
    <button onclick={dismiss}>Let me see...</button>
  </div>
</dialog>

<style>
  dialog[open] {
    display: flex;
    opacity: 1;
    transform: translate(-50%, -50%) scale(1);
  }

  dialog {
    padding: 1.5rem;
    position: fixed;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%) scale(0.75);
    max-width: 60ch;
    flex-direction: column;
    gap: 1rem;
    border: none;
    border-radius: 0.5rem;
    box-shadow: 0 0 4rem rgb(0 0 0 / 0.25);

    opacity: 0;

    transition:
      backdrop-filter 100ms ease-out,
      opacity 100ms ease-out,
      transform 100ms ease-out,
      display 100ms ease-out allow-discrete,
      overlay 100ms ease-out allow-discrete;
  }

  dialog::backdrop {
    background-color: rgb(0 0 0 / 0);
    backdrop-filter: blur(0px);

    transition:
      backdrop-filter 100ms,
      background-color 100ms,
      display 100ms allow-discrete,
      overlay 100ms allow-discrete;
  }

  dialog[open]::backdrop {
    background-color: rgb(0 0 0 / 0.25);
    backdrop-filter: blur(4px);
  }

  @starting-style {
    dialog[open] {
      opacity: 0;
      transform: translate(-50%, -50%) scale(0.75);
    }

    dialog[open]::backdrop {
      background-color: rgb(0 0 0 / 0);
      backdrop-filter: blur(0px);
    }
  }

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

  article {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .controls {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
  }

  .info {
    font-style: italic;
    font-weight: 600;
    color: rgb(0 0 0 / 0.4);
    font-size: 0.9rem;
  }
</style>
