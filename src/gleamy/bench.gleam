import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string

@external(erlang, "os", "perf_counter")
fn perf_counter(_resolution: Int) -> Int {
  panic as "not implemented"
}

/// timestamp in milliseconds
@external(javascript, "../gleamy_bench_ffi.mjs", "now")
pub fn now() -> Float {
  let ns = perf_counter(1_000_000_000)
  int.to_float(ns) /. 1_000_000.0
}

pub type Input(a) {
  Input(label: String, value: a)
}

pub type Function(a, b) {
  Function(label: String, function: fn(a) -> b)
  SetupFunction(label: String, setup_function: fn(a) -> fn(a) -> b)
}

pub type Set {
  Set(input: String, function: String, reps: List(Float))
}

pub type Stat {
  P(Int)
  IPS
  Min
  Max
  Mean
  SD
  SDPercent
  Stat(name: String, calculate: fn(Set) -> Float)
}

fn mean(data: List(Float)) -> Float {
  let count = int.to_float(list.length(data))
  float.sum(data) /. count
}

fn standard_deviation(data: List(Float)) -> Float {
  let count = int.to_float(list.length(data))
  let mean = mean(data)
  let assert Ok(value) =
    {
      float.sum(
        list.map(data, fn(x) {
          let y = x -. mean
          y *. y
        }),
      )
      /. count
    }
    |> float.square_root()
  value
}

fn min(data: List(Float)) -> Float {
  let first = case data {
    [x, ..] -> x
    _ -> 0.0
  }
  list.fold(data, first, fn(a, x) { float.min(a, x) })
}

fn percentile(n: Int, data: List(Float)) {
  let data =
    data
    |> list.sort(float.compare)
    |> list.drop(n * list.length(data) / 100)
  case data {
    [x, ..] -> x
    _ -> 0.0
  }
}

fn max(data: List(Float)) -> Float {
  let first = case data {
    [x, ..] -> x
    _ -> 0.0
  }
  list.fold(data, first, fn(a, x) { float.max(a, x) })
}

fn do_repeat_until(
  acc: List(Float),
  stop: Float,
  value: a,
  fun: fn(a) -> b,
) -> List(Float) {
  let start = now()
  let _result = fun(value)
  let end = now()
  case end {
    _ if end <. stop -> do_repeat_until([end -. start, ..acc], stop, value, fun)
    _ -> acc
  }
}

fn repeat_until(duration: Float, value: a, fun: fn(a) -> b) {
  do_repeat_until([], now() +. duration, value, fun)
}

pub type Option {
  Warmup(ms: Int)
  Duration(ms: Int)
  Decimals(n: Int)
  Quiet
}

pub type Options {
  Options(warmup: Int, duration: Int, decimals: Int, quiet: Bool)
}

pub type BenchResults {
  BenchResults(options: Options, sets: List(Set))
}

fn default_options() -> Options {
  Options(warmup: 500, duration: 2000, decimals: 4, quiet: False)
}

fn apply_options(default: Options, options: List(Option)) -> Options {
  case options {
    [] -> default
    [x, ..xs] ->
      case x {
        Warmup(ms) -> apply_options(Options(..default, warmup: ms), xs)
        Duration(ms) -> apply_options(Options(..default, duration: ms), xs)
        Decimals(n) -> apply_options(Options(..default, decimals: n), xs)
        Quiet -> apply_options(Options(..default, quiet: True), xs)
      }
  }
}

pub fn run(
  inputs: List(Input(a)),
  functions: List(Function(a, b)),
  options: List(Option),
) -> BenchResults {
  let options = apply_options(default_options(), options)
  let results =
    list.flat_map(inputs, fn(input) {
      let Input(input_label, input) = input
      use function <- list.map(functions)
      case function {
        Function(fun_label, fun) -> {
          case options.quiet {
            True -> Nil
            False -> {
              io.println("benching set " <> input_label <> " " <> fun_label)
            }
          }
          let _warmup = repeat_until(int.to_float(options.warmup), input, fun)
          let timings = repeat_until(int.to_float(options.duration), input, fun)
          Set(input_label, fun_label, timings)
        }
        SetupFunction(fun_label, setup_fun) -> {
          case options.quiet {
            True -> Nil
            False -> {
              io.println("benching set " <> input_label <> " " <> fun_label)
            }
          }
          let fun = setup_fun(input)
          let _warmup = repeat_until(int.to_float(options.warmup), input, fun)
          let timings = repeat_until(int.to_float(options.duration), input, fun)
          Set(input_label, fun_label, timings)
        }
      }
    })
  BenchResults(options, results)
}

pub fn do_repeat(n: Int, input: a, fun: fn(a) -> b) {
  case n {
    0 -> Nil
    _ -> {
      let _result = fun(input)
      do_repeat(n - 1, input, fun)
    }
  }
}

pub fn repeat(n: Int, fun: fn(a) -> b) {
  fn(input: a) { do_repeat(n, input, fun) }
}

const name_pad = 20

const stat_pad = 14

fn format_float(f: Float, decimals: Int) {
  let assert Ok(factor) = int.power(10, int.to_float(decimals))
  let whole = float.truncate(f)
  let decimal = float.truncate(f *. factor) - whole * float.truncate(factor)
  string.concat([
    string.pad_left(int.to_string(whole), stat_pad - decimals - 1, " "),
    ".",
    string.pad_left(int.to_string(decimal), decimals, "0"),
  ])
}

fn header_row(stats: List(Stat)) -> String {
  [
    string.pad_right("Input", name_pad, " "),
    string.pad_right("Function", name_pad, " "),
    ..list.map(stats, fn(stat) {
      let stat = case stat {
        P(n) -> "P" <> int.to_string(n)
        IPS -> "IPS"
        Min -> "Min"
        Max -> "Max"
        Mean -> "Mean"
        SD -> "SD"
        SDPercent -> "SD%"
        Stat(name, _) -> name
      }
      string.pad_left(stat, stat_pad, " ")
    })
  ]
  |> string.join("")
}

fn stat_row(set: Set, stats: List(Stat), options: Options) -> String {
  [
    string.pad_right(set.input, name_pad, " "),
    string.pad_right(set.function, name_pad, " "),
    ..list.map(stats, fn(stat) {
      let stat = case stat {
        P(n) -> percentile(n, set.reps)
        IPS ->
          1000.0 *. int.to_float(list.length(set.reps)) /. float.sum(set.reps)
        Min -> min(set.reps)
        Max -> max(set.reps)
        Mean -> mean(set.reps)
        SD -> standard_deviation(set.reps)
        SDPercent -> 100.0 *. standard_deviation(set.reps) /. mean(set.reps)
        Stat(_, calc) -> calc(set)
      }
      stat
      |> format_float(options.decimals)
      |> string.pad_left(stat_pad, " ")
    })
  ]
  |> string.join("")
}

pub fn table(result: BenchResults, stats: List(Stat)) -> String {
  let header = header_row(stats)
  let body = list.map(result.sets, stat_row(_, stats, result.options))
  [header, ..body]
  |> string.join("\n")
}
