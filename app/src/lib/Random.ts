import seedrandom from "seedrandom";

export class Random {
  private rng: seedrandom.PRNG;

  constructor(seed: string) {
    this.rng = seedrandom(seed);
  }

  int(max: number): number {
    return Math.floor(this.rng() * max);
  }

  choose<T>(options: T[]): T {
    return options[this.int(options.length)]!;
  }
}
