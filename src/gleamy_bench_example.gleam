import gleam/int
import gleam/io
import gleam/list
import gleamy/bench

fn sort_int(data) {
  list.sort(data, int.compare)
}

pub fn main() {
  bench.run(
    [
      bench.Input("pre-sorted list", list.range(1, 100_000)),
      bench.Input("reversed list", list.reverse(list.range(1, 100_000))),
    ],
    [bench.Function("list.sort()", sort_int)],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}
