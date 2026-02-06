export function choose<T>(items: T[]): T {
  if (items.length === 0) throw new TypeError("Cannot choose from an empty array");
  return items[Math.floor(Math.random() * items.length)]!;
}
