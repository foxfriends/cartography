<div class="gridlines"></div>

<style>
  .gridlines {
    pointer-events: none;

    position: absolute;
    top: calc(0px - var(--card-size));
    left: calc(0px - var(--card-size));
    width: calc(100% + var(--card-size));
    height: calc(100% + var(--card-size));

    image-rendering: crisp-edges;

    background-position: mod(0px - var(--offset-x), var(--card-size))
      mod(0px - var(--offset-y), var(--card-size));
    background-repeat: repeat;
    background-size: var(--card-size) var(--card-size);
    background-image: linear-gradient(
        rgb(0 0 0 / 12%),
        rgb(0 0 0 / 12%) 1px,
        transparent 1px,
        transparent
      ),
      linear-gradient(
        to right,
        rgb(0 0 0 / 12%),
        rgb(0 0 0 / 12%) 1px,
        transparent 1px,
        transparent
      );
  }
</style>
