import gleam/dynamic/decode
import gleam/json
import gleam/option
import gleam/result
import pog

pub type Error(e) {
  TooManyRows
  NoRows
  QueryError(pog.QueryError)
  HandlerError(e)
}

pub fn one_or_none(
  result: pog.Returned(t),
  with_row: fn(option.Option(t)) -> Result(u, Error(e)),
) -> Result(u, Error(e)) {
  case result.rows {
    [] -> with_row(option.None)
    [row] -> with_row(option.Some(row))
    _ -> Error(TooManyRows)
  }
}

pub fn one(
  result: pog.Returned(t),
  with_row: fn(t) -> Result(u, Error(e)),
) -> Result(u, Error(e)) {
  case result.rows {
    [] -> Error(NoRows)
    [row] -> with_row(row)
    _ -> Error(TooManyRows)
  }
}

pub fn execute(
  query: pog.Query(t),
  database: pog.Connection,
  with_rows: fn(pog.Returned(t)) -> Result(u, Error(e)),
) -> Result(u, Error(e)) {
  use rows <- result.try(
    pog.execute(query, database) |> result.map_error(QueryError),
  )
  with_rows(rows)
}

pub fn json(decoder: decode.Decoder(t)) {
  use json_string <- decode.then(decode.string)
  let assert Ok(result) = json.parse(json_string, decoder)
  decode.success(result)
}
