type Point = { x: number; y: number };

export function nearestEdgeDistance(lhs: Point, rhs: Point): number {
  return Math.min(Math.abs(lhs.x - rhs.x), Math.abs(lhs.y - rhs.y));
}
