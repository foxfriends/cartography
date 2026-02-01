import actor/game_state_watcher
import bus
import envoy
import gleam/erlang/process
import gleam/int
import gleam/otp/factory_supervisor
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
    |> result.unwrap(12_000)

  let db_name = process.new_name("database")
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(db_config) = pog.url_config(db_name, database_url)
  let database =
    db_config
    |> pog.pool_size(10)
    |> pog.supervised()

  let #(bus_process, bus_handles) = bus.supervised()

  let game_state_watcher_supervisor_name =
    process.new_name("game_state_watcher_supervisor")
  let factory =
    factory_supervisor.worker_child(game_state_watcher.start)
    |> factory_supervisor.named(game_state_watcher_supervisor_name)
    |> factory_supervisor.supervised()

  let context =
    context.Context(
      db_name,
      bus_handles,
      game_state_watchers: game_state_watcher_supervisor_name,
    )
  let server =
    mist.new(router.handler(_, context))
    |> mist.port(port)
    |> mist.supervised()

  let assert Ok(_) =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.add(database)
    |> static_supervisor.add(bus_process)
    |> static_supervisor.add(factory)
    |> static_supervisor.add(server)
    |> static_supervisor.start()

  process.sleep_forever()
}
