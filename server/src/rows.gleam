import gleam/option
import pog

pub type Error(e) {
  TooManyRows
  NoRows
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
