import coder.{type Coder}
import gleam/result

pub type CodecError(decoding_error, encoding_error) {
  DecodingError(decoding_error)
  EncodingError(encoding_error)
}

pub opaque type Codec(from, to, from_error, to_error) {
  Codec(
    from_coder: Coder(from, from_error, from_error),
    to_coder: Coder(to, to_error, to_error),
  )
}

pub fn codec(
  from from_coder: Coder(from, from_error, from_error),
  to to_coder: Coder(to, to_error, to_error),
) -> Codec(from, to, from_error, to_error) {
  Codec(from_coder:, to_coder:)
}

pub fn encode(
  codec: Codec(from, to, from_error, to_error),
  data: from,
) -> Result(to, CodecError(from_error, to_error)) {
  use codable <- result.try(
    data |> coder.decode(codec.from_coder) |> result.map_error(DecodingError),
  )
  use encoding <- result.try(
    codable |> coder.encode(codec.to_coder) |> result.map_error(EncodingError),
  )
  Ok(encoding)
}

pub fn decode(
  codec: Codec(from, to, from_error, to_error),
  data: to,
) -> Result(from, CodecError(to_error, from_error)) {
  use codable <- result.try(
    data |> coder.decode(codec.to_coder) |> result.map_error(DecodingError),
  )
  use decoding <- result.try(
    codable |> coder.encode(codec.from_coder) |> result.map_error(EncodingError),
  )
  Ok(decoding)
}
