import gleam/json
import models/tile_category

pub type TileType {
  TileType(
    id: String,
    category: tile_category.TileCategory,
    houses: Int,
    employs: Int,
  )
}

pub fn to_json(card_type: TileType) {
  json.object([
    #("id", json.string(card_type.id)),
    #("category", json.string(tile_category.to_string(card_type.category))),
    #("houses", json.int(card_type.houses)),
    #("employs", json.int(card_type.employs)),
  ])
}
