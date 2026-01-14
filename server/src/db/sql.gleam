//// This module contains the code to run the sql queries defined in
//// `./src/db/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
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
