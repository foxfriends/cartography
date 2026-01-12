import gleam/dynamic/decode

pub type CardClass {
  Tile
  Citizen
}

pub fn decoder() {
  use value <- decode.then(decode.string)
  case value {
    "tile" -> decode.success(Tile)
    "citizen" -> decode.success(Citizen)
    _ -> decode.failure(Tile, "card class value")
  }
}

pub fn to_string(class: CardClass) {
  case class {
    Tile -> "tile"
    Citizen -> "citizen"
  }
}
