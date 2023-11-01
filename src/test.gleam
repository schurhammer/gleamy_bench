import gleam/io

pub type Ctrl(a) {
  Pure(a)
  Yield(
    marker: String,
    op: fn(fn(a) -> Ctrl(a)) -> Ctrl(a),
    cont: fn(a) -> Ctrl(a),
  )
}

fn kcompose(g, f) {
  fn(x) {
    f(x)
    |> bind(g)
  }
}

fn bind(ctl, f) -> Ctrl(a) {
  case ctl {
    Pure(x) -> f(x)
    Yield(m, op, cont) -> Yield(m, op, kcompose(f, cont))
  }
}

pub fn yield(marker, op) {
  Yield(marker, op, Pure)
}

pub fn prompt(marker, action) {
  mprompt(marker, action())
}

pub fn mprompt(marker, ctl) {
  case ctl {
    Pure(x) -> Pure(x)
    Yield(m, op, cont) -> {
      let cont = fn(x) { mprompt(marker, cont(x)) }
      case marker == m {
        True -> op(cont)
        False -> Yield(m, op, cont)
      }
    }
  }
}

pub fn main() {
  run()
  |> io.debug
  io.println("Hello from deli!")
}

fn run() {
  prompt(
    "read",
    fn() {
      use a <- bind(Pure(5))
      use b <- bind(yield("read", fn(k) { k(2) }))
      Pure(a + b)
    },
  )
}
