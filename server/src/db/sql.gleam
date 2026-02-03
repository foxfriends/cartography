//// This module contains the code to run the sql queries defined in
//// `./src/db/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// A row you get from running the `create_account` query
/// defined in `./src/db/sql/create_account.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateAccountRow {
  CreateAccountRow(id: String)
}

/// Runs the `create_account` query
/// defined in `./src/db/sql/create_account.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_account(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(CreateAccountRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    decode.success(CreateAccountRow(id:))
  }

  "INSERT INTO
  accounts (id)
VALUES
  ($1)
ON CONFLICT DO NOTHING
RETURNING
  *
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_citizen` query
/// defined in `./src/db/sql/create_citizen.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateCitizenRow {
  CreateCitizenRow(card_id: Int, account_id: String)
}

/// Runs the `create_citizen` query
/// defined in `./src/db/sql/create_citizen.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_citizen(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
) -> Result(pog.Returned(CreateCitizenRow), pog.QueryError) {
  let decoder = {
    use card_id <- decode.field(0, decode.int)
    use account_id <- decode.field(1, decode.string)
    decode.success(CreateCitizenRow(card_id:, account_id:))
  }

  "WITH
  cards_inserted AS (
    INSERT INTO
      cards (card_type_id)
    VALUES
      ($1)
    RETURNING
      *
  ),
  citizens_inserted AS (
    INSERT INTO
      citizens (id, species_id, name)
    SELECT
      card.id,
      card.card_type_id,
      ''
    FROM
      cards_inserted card
  )
INSERT INTO
  card_accounts (card_id, account_id)
SELECT
  card.id,
  $2
FROM
  cards_inserted card
RETURNING
  *;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_tile` query
/// defined in `./src/db/sql/create_tile.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateTileRow {
  CreateTileRow(card_id: Int, account_id: String)
}

/// Runs the `create_tile` query
/// defined in `./src/db/sql/create_tile.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_tile(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
) -> Result(pog.Returned(CreateTileRow), pog.QueryError) {
  let decoder = {
    use card_id <- decode.field(0, decode.int)
    use account_id <- decode.field(1, decode.string)
    decode.success(CreateTileRow(card_id:, account_id:))
  }

  "WITH
  cards_inserted AS (
    INSERT INTO
      cards (card_type_id)
    VALUES
      ($1)
    RETURNING
      *
  ),
  tiles_inserted AS (
    INSERT INTO
      tiles (id, tile_type_id, name)
    SELECT
      card.id,
      card.card_type_id,
      ''
    FROM
      cards_inserted card
  )
INSERT INTO
  card_accounts (card_id, account_id)
SELECT
  card.id,
  $2
FROM
  cards_inserted card
RETURNING
  *;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_account` query
/// defined in `./src/db/sql/get_account.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAccountRow {
  GetAccountRow(id: String)
}

/// Runs the `get_account` query
/// defined in `./src/db/sql/get_account.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_account(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(GetAccountRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    decode.success(GetAccountRow(id:))
  }

  "SELECT
  *
FROM
  accounts
WHERE
  id = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_card_type` query
/// defined in `./src/db/sql/get_card_type.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetCardTypeRow {
  GetCardTypeRow(id: String, card_set_id: String, class: CardClass)
}

/// Runs the `get_card_type` query
/// defined in `./src/db/sql/get_card_type.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_card_type(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(GetCardTypeRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use card_set_id <- decode.field(1, decode.string)
    use class <- decode.field(2, card_class_decoder())
    decode.success(GetCardTypeRow(id:, card_set_id:, class:))
  }

  "SELECT
  *
FROM
  card_types
WHERE
  id = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_field_and_tiles_by_id` query
/// defined in `./src/db/sql/get_field_and_tiles_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFieldAndTilesByIdRow {
  GetFieldAndTilesByIdRow(field: String, field_tiles: String)
}

/// Runs the `get_field_and_tiles_by_id` query
/// defined in `./src/db/sql/get_field_and_tiles_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_field_and_tiles_by_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetFieldAndTilesByIdRow), pog.QueryError) {
  let decoder = {
    use field <- decode.field(0, decode.string)
    use field_tiles <- decode.field(1, decode.string)
    decode.success(GetFieldAndTilesByIdRow(field:, field_tiles:))
  }

  "SELECT
  to_json(fields.*) AS field,
  json_arrayagg (field_tiles.* ABSENT ON NULL) AS field_tiles
FROM
  fields
  LEFT JOIN field_tiles ON field_tiles.field_id = fields.id
WHERE
  fields.id = $1
GROUP BY
  fields.id
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_field_by_id` query
/// defined in `./src/db/sql/get_field_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFieldByIdRow {
  GetFieldByIdRow(id: Int, name: String, account_id: String)
}

/// Runs the `get_field_by_id` query
/// defined in `./src/db/sql/get_field_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_field_by_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetFieldByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use account_id <- decode.field(2, decode.string)
    decode.success(GetFieldByIdRow(id:, name:, account_id:))
  }

  "SELECT
  *
FROM
  fields
WHERE
  id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_field_citizens` query
/// defined in `./src/db/sql/get_field_citizens.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFieldCitizensRow {
  GetFieldCitizensRow(
    citizen_id: Int,
    account_id: String,
    field_id: Int,
    grid_x: Int,
    grid_y: Int,
  )
}

/// Runs the `get_field_citizens` query
/// defined in `./src/db/sql/get_field_citizens.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_field_citizens(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetFieldCitizensRow), pog.QueryError) {
  let decoder = {
    use citizen_id <- decode.field(0, decode.int)
    use account_id <- decode.field(1, decode.string)
    use field_id <- decode.field(2, decode.int)
    use grid_x <- decode.field(3, decode.int)
    use grid_y <- decode.field(4, decode.int)
    decode.success(GetFieldCitizensRow(
      citizen_id:,
      account_id:,
      field_id:,
      grid_x:,
      grid_y:,
    ))
  }

  "SELECT
 *
FROM
  field_citizens
WHERE
  field_citizens.field_id = $1;
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_field_tiles` query
/// defined in `./src/db/sql/get_field_tiles.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFieldTilesRow {
  GetFieldTilesRow(
    tile_id: Int,
    account_id: String,
    field_id: Int,
    grid_x: Int,
    grid_y: Int,
  )
}

/// Runs the `get_field_tiles` query
/// defined in `./src/db/sql/get_field_tiles.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_field_tiles(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetFieldTilesRow), pog.QueryError) {
  let decoder = {
    use tile_id <- decode.field(0, decode.int)
    use account_id <- decode.field(1, decode.string)
    use field_id <- decode.field(2, decode.int)
    use grid_x <- decode.field(3, decode.int)
    use grid_y <- decode.field(4, decode.int)
    decode.success(GetFieldTilesRow(
      tile_id:,
      account_id:,
      field_id:,
      grid_x:,
      grid_y:,
    ))
  }

  "SELECT
 *
FROM
  field_tiles
WHERE
  field_tiles.field_id = $1;
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_player_deck` query
/// defined in `./src/db/sql/get_player_deck.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPlayerDeckRow {
  GetPlayerDeckRow(
    id: Int,
    name: String,
    tile_type_id: Option(String),
    species_id: Option(String),
    home_tile_id: Option(Int),
  )
}

/// Runs the `get_player_deck` query
/// defined in `./src/db/sql/get_player_deck.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_player_deck(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(GetPlayerDeckRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use tile_type_id <- decode.field(2, decode.optional(decode.string))
    use species_id <- decode.field(3, decode.optional(decode.string))
    use home_tile_id <- decode.field(4, decode.optional(decode.int))
    decode.success(GetPlayerDeckRow(
      id:,
      name:,
      tile_type_id:,
      species_id:,
      home_tile_id:,
    ))
  }

  "SELECT
  cards.id as id,
  coalesce(tiles.name, citizens.name) as name,
  tiles.tile_type_id,
  citizens.species_id,
  citizens.home_tile_id
FROM
  cards
  INNER JOIN card_accounts ON card_accounts.card_id = cards.id
  LEFT OUTER JOIN citizens ON cards.id = citizens.id
  LEFT OUTER JOIN tiles ON cards.id = tiles.id
WHERE
  card_accounts.account_id = $1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `list_fields_for_account` query
/// defined in `./src/db/sql/list_fields_for_account.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ListFieldsForAccountRow {
  ListFieldsForAccountRow(id: Int, name: String, account_id: String)
}

/// Runs the `list_fields_for_account` query
/// defined in `./src/db/sql/list_fields_for_account.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn list_fields_for_account(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(ListFieldsForAccountRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use account_id <- decode.field(2, decode.string)
    decode.success(ListFieldsForAccountRow(id:, name:, account_id:))
  }

  "SELECT
  *
FROM
  fields
WHERE
  account_id = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Enums -------------------------------------------------------------------

/// Corresponds to the Postgres `card_class` enum.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CardClass {
  Citizen
  Tile
}

fn card_class_decoder() -> decode.Decoder(CardClass) {
  use card_class <- decode.then(decode.string)
  case card_class {
    "citizen" -> decode.success(Citizen)
    "tile" -> decode.success(Tile)
    _ -> decode.failure(Citizen, "CardClass")
  }
}
