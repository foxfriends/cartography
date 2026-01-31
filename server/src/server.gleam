import bus
import envoy
import gleam/erlang/process
import gleam/int
import gleam/otp/static_supervisor
import gleam/result
import mist
import palabres
import palabres/options
import pog
import server/context
import server/router

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

  let #(bus_process, bus_handles) = bus.supervised()

  let context = context.Context(db_name, bus_handles)
  let server =
    mist.new(router.handler(_, context))
    |> mist.port(port)
    |> mist.supervised()

  let assert Ok(_) =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.add(database)
    |> static_supervisor.add(bus_process)
    |> static_supervisor.add(server)
    |> static_supervisor.start()

  process.sleep_forever()
}
