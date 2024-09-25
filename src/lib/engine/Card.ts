import type { Card, ProductionCard, SourceCard } from "$lib/data/cards";
import type { Geography } from "$lib/types";
import type { FieldCard } from "./FieldCard";

export function isDependent(consumer: Card, producer: Card) {
  if (consumer.category !== "production") return false;
  if (producer.category !== "production" && producer.category !== "source") return false;
  return consumer.inputs.some((input) =>
    producer.outputs.some((output) => output.resource === input.resource),
  );
}

export function sourceIsProducing(
  { card, field }: { card: SourceCard; field: FieldCard },
  geography: Geography,
) {
  return card.source.some((source) => {
    switch (source.type) {
      case "terrain":
        if (geography.terrain[field.y]?.[field.x]?.type === source.terrain) {
          return true;
        }
        break;
      case "any":
        return true;
    }
  });
}

export type ProducingCard = SourceCard | ProductionCard;
export function canProduce(card: Card): card is ProducingCard {
  return card.category === "source" || card.category === "production";
}

declare const __brand: unique symbol;
export type CardId = string & { [__brand]: "CardId" };

export function generateCardId(): CardId {
  return window.crypto.randomUUID() as CardId;
}
