import gleam/dynamic/decode

pub type CardCategory {
  Residential
  Production
  Amenity
  Source
  Trade
  Transportation
}

pub fn decoder() {
  use value <- decode.then(decode.string)
  case value {
    "residential" -> decode.success(Residential)
    "production" -> decode.success(Production)
    "amenity" -> decode.success(Amenity)
    "source" -> decode.success(Source)
    "trade" -> decode.success(Trade)
    "transportation" -> decode.success(Transportation)
    _ -> decode.failure(Residential, "card category value")
  }
}

pub fn to_string(category: CardCategory) {
  case category {
    Residential -> "residential"
    Production -> "production"
    Amenity -> "amenity"
    Source -> "source"
    Trade -> "trade"
    Transportation -> "transportation"
  }
}
