import type { Pack } from "$lib/engine/Pack";

export class BuyPackEvent extends Event {
  pack: Pack;

  constructor(pack: Pack) {
    super("buypack");
    this.pack = pack;
  }
}
