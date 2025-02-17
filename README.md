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

## Function with additional setup

Sometimes you need to do some additional setup before you can call your function, instead of having it called directly with the input data.
For this use case you can use bench.SetupFunction

`SetupFunction(label: String, setup_function: fn(a) -> fn(a) -> b)`

The setup function is executed once at the start of the run, and should return the function that will be benchmarked.
Both the setup function and the benchmark function will be passed the input data.

For example, you might be testing the speed of a certain operation on a range of data structures.
To do this you will need to create each data structure beforehand with the given input data so you can run the operation on it.

```gleam
bench.run(
  [
    bench.Input("100", list.range(1, 100)),
    bench.Input("1000", list.reverse(list.range(1, 1000))),
  ],
  [
    bench.SetupFunction("dict.get", fn(items) {
      // This section will not be measured in the benchmark.
      // We fill a dictionary with the input items to use later.
      let d = list.fold(items, dict.new(), fn(d, i) {
        dict.insert(d, i, i)
      })

      // The returned function will be measured for the benchmark.
      // It tries to "get" each item in the input from the dictionary.
      fn(items) {
        list.each(items, fn(i) { dict.get(d, i) })
      }
    })

    // ...
  ],
  [bench.Duration(1000), bench.Warmup(100)],
)
```

## Contributing

Suggestions and pull requests are welcome!

## Installation

This package can be added to your Gleam project:

```sh
gleam add gleamy_bench
```

and its documentation can be found at <https://hexdocs.pm/gleamy_bench>.
