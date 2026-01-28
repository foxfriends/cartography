import game_state.{type GameState}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import repr
import squirtle.{type Patch}

/// A response is sent from the server to the client.
pub opaque type Response {
  PutData(GameState)
  PatchData(List(Patch))
}

pub fn to_string(response: Response) -> String {
  json.to_string(case response {
    PutData(game_state) ->
      game_state.to_json(game_state)
      |> repr.struct("PutData")
    PatchData(patches) ->
      patches
      |> list.map(squirtle.patch_to_json_value)
      |> list.map(squirtle.json_value_to_gleam_json)
      |> json.preprocessed_array()
      |> repr.struct("PatchData")
  })
}

pub fn from_string(string: String) -> Result(Response, json.DecodeError) {
  json.parse(string, {
    use tag <- repr.struct_tag(PatchData([]))
    case tag {
      "PutData" -> {
        use payload <- repr.struct_payload(game_state.decoder())
        decode.success(PutData(payload))
      }
      "PatchData" -> {
        use payload <- repr.struct_payload(
          decode.list(squirtle.patch_decoder()),
        )
        decode.success(PatchData(payload))
      }
      _ -> {
        decode.failure(PatchData([]), "valid #tag")
      }
    }
  })
}

pub fn put_data(game_state: GameState) -> Response {
  PutData(game_state)
}

pub fn patch_data(patches: List(Patch)) -> Response {
  PatchData(patches)
}
