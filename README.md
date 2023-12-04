# gleamy_bench

[![Package Version](https://img.shields.io/hexpm/v/gleamy_bench)](https://hex.pm/packages/gleamy_bench)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleamy_bench/)

A library for benchmarking gleam code.

# How To

```gleam
import gleamy/bench

// ...

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
```

A benchmark is defined by giving a list of inputs and a list of functions to run on those inputs. Each input + function combination will be timed.

The given inputs should all be the same type, and the functions should all accept that type as the only argument.

The `run` function actually runs the benchmark and collects the results. It also accepts a list of options to change default behaviour, for example `Duration(1000)` is used to change how long each function is run repeatedly when collecting results (in milliseconds). This list is optional and can be empty if you have no need to change the defaults.

The `table` function makes a table out of the results. You can choose the list of statistics you would like to include in the table.

The output for this example looks like the following.

```
Input                   Function                           IPS             Min             P99
pre-sorted list         list.sort()                    37.8532         22.4190         31.3593
reversed list           list.sort()                    34.0101         27.0734         31.0618
```

## Contributing

Suggestions and pull requests are welcome!

## Installation

This package can be added to your Gleam project:

```sh
gleam add gleamy_bench
```

and its documentation can be found at <https://hexdocs.pm/gleamy_bench>.
