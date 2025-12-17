import context
import envoy
import gleam/erlang/process
import gleam/int
import gleam/otp/static_supervisor as sup
import gleam/result
import mist
import palabres
import palabres/options
import pog

import router

pub fn main() -> Nil {
  options.defaults()
  |> options.color(True)
  |> options.json(True)
  |> options.output(to: options.stdout())
  |> palabres.configure()

  let port =
    envoy.get("PORT")
    |> result.try(int.parse)
    |> result.unwrap(8000)

  let db_name = process.new_name("database")
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(db_config) = pog.url_config(db_name, database_url)
  let database =
    db_config
    |> pog.pool_size(10)
    |> pog.supervised()

  let context = context.Context(db_name)

  let server =
    mist.new(fn(req) { router.handler(req, context) })
    |> mist.port(port)
    |> mist.supervised()

  let assert Ok(_) =
    sup.new(sup.OneForOne)
    |> sup.add(database)
    |> sup.add(server)
    |> sup.start()

  process.sleep_forever()
}
