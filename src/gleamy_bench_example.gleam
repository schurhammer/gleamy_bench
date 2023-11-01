import gleamy_bench.{Bench, Function, IPS, Input, Min, P, run, table}
import gleam/io

fn fib1(n: Int) -> Int {
  case n {
    0 -> 0
    1 -> 1
    n -> fib1(n - 1) + fib1(n - 2)
  }
}

fn do_fib2(a, b, n) {
  case n {
    0 -> a
    _ -> do_fib2(b, a + b, n - 1)
  }
}

fn fib2(n: Int) -> Int {
  do_fib2(0, 1, n)
}

pub fn main() {
  Bench(
    [Input("n=5", 5), Input("n=10", 10), Input("n=15", 15)],
    [Function("fib1", fib1), Function("fib2", fib2)],
  )
  |> run()
  |> table([IPS, Min, P(99)])
  |> io.println()
}
