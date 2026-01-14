import gleam/dynamic/decode
import gleam/json
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp

pub type CardSet {
  CardSet(id: String, release_date: timestamp.Timestamp)
}

pub fn to_json(card_set: CardSet) {
  json.object([
    #("id", json.string(card_set.id)),
    #(
      "release_date",
      card_set.release_date
        |> timestamp.to_rfc3339(calendar.utc_offset)
        |> json.string(),
    ),
  ])
}

pub fn from_json() {
  use id <- decode.field("id", decode.string)
  use release_date <- decode.field("release_date", decode.string)
  case timestamp.parse_rfc3339(release_date) {
    Ok(release_date) -> decode.success(CardSet(id:, release_date:))
    Error(error) ->
      decode.failure(
        CardSet(id:, release_date: timestamp.unix_epoch),
        string.inspect(error),
      )
  }
}
