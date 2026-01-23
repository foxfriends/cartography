import gleam/dict.{type Dict}

pub type Codable {
  Nil
  Bool(Bool)
  Int(Int)
  Float(Float)
  String(String)
  Binary(BitArray)
  List(List(Codable))
  Record(Dict(String, Codable))
  Struct(String, Codable)
}
