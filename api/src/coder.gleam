import codable.{type Codable}
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/function
import gleam/json.{type Json} as gleam_json
import gleam/list
import gleam/option
import gleam/result
import glepack/data as glepack_data
import glepack/decode as glepack_decode
import glepack/encode as glepack_encode
import glepack/error as glepack_error

pub opaque type Coder(encoding, err) {
  Coder(
    encode: fn(Codable) -> Result(encoding, err),
    decode: fn(encoding) -> Result(Codable, err),
  )
}

pub fn encode(
  data: Codable,
  codec: Coder(encoding, err),
) -> Result(encoding, err) {
  codec.encode(data)
}

pub fn decode(
  data: encoding,
  codec: Coder(encoding, err),
) -> Result(Codable, err) {
  codec.decode(data)
}

pub type JsonError {
  JsonError(gleam_json.DecodeError)
}

pub const json = Coder(encode: encode_json, decode: decode_json)

fn codable_to_json(codable: Codable) -> Json {
  case codable {
    codable.Nil -> gleam_json.null()
    codable.Bool(bool) -> gleam_json.bool(bool)
    codable.Int(int) -> gleam_json.int(int)
    codable.Float(float) -> gleam_json.float(float)
    codable.String(string) -> gleam_json.string(string)
    codable.List(list) -> gleam_json.array(list, codable_to_json)
    codable.Binary(binary) ->
      gleam_json.object([
        #("#type", gleam_json.string("binary")),
        #("#payload", gleam_json.string(bit_array.base64_encode(binary, False))),
      ])
    codable.Record(record) ->
      gleam_json.object([
        #("#type", gleam_json.string("record")),
        #(
          "#payload",
          gleam_json.dict(record, function.identity, codable_to_json),
        ),
      ])
    codable.Struct(tag, value) ->
      gleam_json.object([
        #("#type", gleam_json.string("struct")),
        #("#tag", gleam_json.string(tag)),
        #("#payload", codable_to_json(value)),
      ])
  }
}

fn json_to_codable() -> decode.Decoder(Codable) {
  let typed_decoder = {
    use type_key <- decode.field("#type", decode.string)
    case type_key {
      "binary" -> {
        use payload <- decode.field("#payload", decode.string)
        case bit_array.base64_decode(payload) {
          Ok(binary) -> decode.success(codable.Binary(binary))
          Error(_) ->
            decode.failure(codable.Binary(<<>>), "base64 encoded string")
        }
      }
      "record" -> {
        use payload <- decode.field(
          "#payload",
          decode.dict(decode.string, json_to_codable()),
        )
        decode.success(codable.Record(payload))
      }
      "struct" -> {
        use tag <- decode.field("#tag", decode.string)
        use payload <- decode.field("#payload", json_to_codable())
        decode.success(codable.Struct(tag, payload))
      }
      _ -> decode.failure(codable.Nil, "`binary`, `struct`, or `record`")
    }
  }
  use opt <- decode.map(
    decode.optional(
      decode.one_of(typed_decoder, [
        decode.map(decode.bool, codable.Bool),
        decode.map(decode.float, codable.Float),
        decode.map(decode.int, codable.Int),
        decode.map(decode.string, codable.String),
        decode.map(decode.list(json_to_codable()), codable.List),
      ]),
    ),
  )
  case opt {
    option.Some(value) -> value
    option.None -> codable.Nil
  }
}

fn encode_json(codable: Codable) -> Result(String, JsonError) {
  codable
  |> codable_to_json()
  |> gleam_json.to_string()
  |> Ok()
}

fn decode_json(json_string: String) -> Result(Codable, JsonError) {
  gleam_json.parse(json_string, json_to_codable())
  |> result.map_error(JsonError)
}

pub type MessagePackError {
  MessagePackError(glepack_error.DecodeError)
  NonTotalMessage(Codable, BitArray)
  MapKeysMustBeStrings
  StructTagMustBeString
  UnknownExtension(Int)
}

pub const messagepack = Coder(
  encode: encode_messagepack,
  decode: decode_messagepack,
)

fn codable_to_messagepack(codable: Codable) -> glepack_data.Value {
  case codable {
    codable.Nil -> glepack_data.Nil
    codable.Bool(bool) -> glepack_data.Boolean(bool)
    codable.Int(int) -> glepack_data.Integer(int)
    codable.Float(float) -> glepack_data.Float(float)
    codable.String(string) -> glepack_data.String(string)
    codable.Binary(binary) -> glepack_data.Binary(binary)
    codable.List(list) ->
      glepack_data.Array(list.map(list, codable_to_messagepack))
    codable.Record(dict) ->
      dict
      |> dict.to_list()
      |> list.map(fn(tuple) {
        let #(key, value) = tuple
        #(glepack_data.String(key), codable_to_messagepack(value))
      })
      |> dict.from_list()
      |> glepack_data.Map()
    codable.Struct(tag, value) -> {
      let assert Ok(key) = glepack_encode.string(tag)
      let assert Ok(value) = encode_messagepack(value)
      glepack_data.Extension(0, bit_array.append(key, value))
    }
  }
}

fn messagepack_to_codable(
  value: glepack_data.Value,
) -> Result(Codable, MessagePackError) {
  case value {
    glepack_data.Nil -> Ok(codable.Nil)
    glepack_data.Boolean(bool) -> Ok(codable.Bool(bool))
    glepack_data.Integer(int) -> Ok(codable.Int(int))
    glepack_data.Float(float) -> Ok(codable.Float(float))
    glepack_data.String(string) -> Ok(codable.String(string))
    glepack_data.Binary(binary) -> Ok(codable.Binary(binary))
    glepack_data.Array(array) -> {
      list.map(array, messagepack_to_codable)
      |> result.all()
      |> result.map(codable.List)
    }
    glepack_data.Map(map) ->
      map
      |> dict.to_list()
      |> list.map(fn(tuple) {
        case tuple {
          #(glepack_data.String(string), value) -> {
            use codable <- result.try(messagepack_to_codable(value))
            Ok(#(string, codable))
          }
          _ -> Error(MapKeysMustBeStrings)
        }
      })
      |> result.all()
      |> result.map(fn(pairs) { pairs |> dict.from_list() |> codable.Record() })
    glepack_data.Extension(0, bit_array) -> {
      use #(tag, trailer) <- result.try(
        glepack_decode.value(bit_array) |> result.map_error(MessagePackError),
      )
      use tag <- result.try(case tag {
        glepack_data.String(tag) -> Ok(tag)
        _ -> Error(StructTagMustBeString)
      })
      use payload <- result.try(decode_messagepack(trailer))
      Ok(codable.Struct(tag, payload))
    }
    glepack_data.Extension(ext, _) -> {
      Error(UnknownExtension(ext))
    }
  }
}

fn encode_messagepack(codable: Codable) -> Result(BitArray, MessagePackError) {
  let assert Ok(bits) =
    codable_to_messagepack(codable)
    |> glepack_encode.value()
  Ok(bits)
}

fn decode_messagepack(bit_array: BitArray) -> Result(Codable, MessagePackError) {
  use #(value, trailer) <- result.try(
    glepack_decode.value(bit_array) |> result.map_error(MessagePackError),
  )
  use value <- result.try(messagepack_to_codable(value))
  case trailer {
    <<>> -> Ok(value)
    _ -> Error(NonTotalMessage(value, trailer))
  }
}
