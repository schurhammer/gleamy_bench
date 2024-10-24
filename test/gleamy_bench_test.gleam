import gleam/int
import gleamy/bench
import gleeunit
import gleeunit/should

fn do_busy_sleep(until: Float) {
  case bench.now() {
    now if now >. until -> Nil
    _ -> do_busy_sleep(until)
  }
}

fn sleep(ms: Int) -> Nil {
  do_busy_sleep(bench.now() +. int.to_float(ms))
}

pub fn main() {
  gleeunit.main()
}

pub fn bench_run_test() {
  bench.run(
    [bench.Input("10ms", 10), bench.Input("20ms", 20)],
    [
      bench.Function("sleep1", fn(ms) { sleep(ms) }),
      bench.SetupFunction("sleep2", fn(ms) { fn(_) { sleep(ms) } }),
      bench.SetupFunction("sleep3", fn(_) { fn(ms) { sleep(ms) } }),
    ],
    [bench.Duration(100), bench.Warmup(10), bench.Decimals(0)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> should.equal(
    "Input               Function                       IPS           Min           P99
10ms                sleep1                         99.0           10.0           10.0
10ms                sleep2                         99.0           10.0           10.0
10ms                sleep3                         99.0           10.0           10.0
20ms                sleep1                         49.0           20.0           20.0
20ms                sleep2                         49.0           20.0           20.0
20ms                sleep3                         49.0           20.0           20.0",
  )
}
