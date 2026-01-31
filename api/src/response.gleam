import account.{type Account}
import game_state.{type GameState}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import repr
import squirtle.{type Patch}
import youid/uuid.{type Uuid}

pub opaque type Message {
  Message(nonce: Int, id: Uuid, response: Response)
}

pub fn message(response: Response, id: String, nonce: Int) -> Message {
  let assert Ok(id) = uuid.from_string(id)
  Message(nonce:, id:, response:)
}

pub fn id(message: Message) -> String {
  uuid.to_string(message.id)
}

pub fn response(message: Message) -> Response {
  message.response
}

/// A response is sent from the server to the client.
///
/// A response does not necessarily respond to something, it might just be a pushed notification.
pub opaque type Response {
  Authenticated(Account)
  PutData(GameState)
  PatchData(List(Patch))
}

pub fn to_json(message: Message) -> json.Json {
  let Message(nonce, id, response) = message
  let response = case response {
    Authenticated(account) ->
      account.to_json(account)
      |> repr.struct("Authenticated")
    PutData(game_state) ->
      game_state.to_json(game_state)
      |> repr.struct("PutData")
    PatchData(patches) ->
      patches
      |> list.map(squirtle.patch_to_json_value)
      |> list.map(squirtle.json_value_to_gleam_json)
      |> json.preprocessed_array()
      |> repr.struct("PatchData")
  }
  json.object([
    #("nonce", json.int(nonce)),
    #("id", json.string(uuid.to_string(id))),
    #("response", response),
  ])
}

pub fn to_string(message: Message) -> String {
  message
  |> to_json()
  |> json.to_string()
}

pub fn from_string(string: String) -> Result(Message, json.DecodeError) {
  json.parse(string, {
    use nonce <- decode.field("nonce", decode.int)
    use id <- decode.field("id", repr.uuid())
    use response <- decode.field("response", {
      use tag <- repr.struct_tag(PatchData([]))
      case tag {
        "Authenticated" -> {
          use payload <- repr.struct_payload(account.decoder())
          decode.success(Authenticated(payload))
        }
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
    decode.success(Message(nonce:, id:, response:))
  })
}

pub fn authenticated(account: Account) -> Response {
  Authenticated(account)
}

pub fn put_data(game_state: GameState) -> Response {
  PutData(game_state)
}

pub fn patch_data(patches: List(Patch)) -> Response {
  PatchData(patches)
}
