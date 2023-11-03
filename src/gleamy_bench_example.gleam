import gleamy_bench as bench
import gleam/io
import gleam/int
import gleam/list

fn sort_int(data) {
  list.sort(data, int.compare)
}

pub fn main() {
  bench.run(
    [
      bench.Input("pre-sorted list", list.range(1, 100_000)),
      bench.Input(
        "reversed list",
        list.range(1, 100_000)
        |> list.reverse,
      ),
    ],
    [bench.Function("list.sort()", sort_int)],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}
