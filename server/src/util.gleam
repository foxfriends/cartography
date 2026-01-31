import gleam/option

pub fn with_some(v: v, option: option.Option(t), do: fn(v, t) -> v) -> v {
  case option {
    option.Some(t) -> do(v, t)
    option.None -> v
  }
}
