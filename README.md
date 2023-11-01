# gleamy_bench

[![Package Version](https://img.shields.io/hexpm/v/gleamy_bench)](https://hex.pm/packages/gleamy_bench)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleamy_bench/)

A library for benchmarking gleam code.

# How To

```rust
import gleamy_bench.{Bench, BenchTime, Function, IPS, Input, Min, P, run, table}

// ..

Bench(
    [
        Input("n=5", 5),
        Input("n=10", 10),
        Input("n=15", 15),
    ],
    [
        Function("fib1", fib1),
        Function("fib2", fib2),
    ],
)
|> run([BenchTime(500)])
|> table([IPS, Min, P(99)])
|> io.println()

```

A benchmark is defined by giving a list of inputs and a list of functions to run on those inputs. Each input + function combination will be timed.

The inputs should all be the same type, and the functions should all accept that type as the only argument. The return type of the function does not matter, only that they all return the same type.

The `run` function actually runs the benchmark and collects the results. It accepts a list of options to change default behaviour, for example `BenchTime(100)` can be used to change how long each function is run repeatedly when collecting results (in milliseconds).

The `table` function makes a table out of the results. You can choose the list of statistics you would like to include in the table.

The output for this example looks like the following.

```
Input                   Function                           IPS             Min             P99
n=5                     fib1                      2236277.3002          0.0002          0.0006
n=5                     fib2                      2493122.7461          0.0002          0.0006
n=10                    fib1                       750561.7961          0.0010          0.0022
n=10                    fib2                      2755751.7477          0.0002          0.0005
n=15                    fib1                        80833.4127          0.0102          0.0184
n=15                    fib2                      2139409.1371          0.0003          0.0007
```

## Contributing

Suggestions and pull requests are welcome!

## Quick start

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```

## Installation

If available on Hex this package can be added to your Gleam project:

```sh
gleam add gleamy_bench
```

and its documentation can be found at <https://hexdocs.pm/gleamy_bench>.
