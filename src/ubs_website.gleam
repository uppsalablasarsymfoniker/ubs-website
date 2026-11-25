// IMPORTS ---------------------------------------------------------------------

import argv
import gleam/io
import ubs_website/build
import ubs_website/error

// MAIN ------------------------------------------------------------------------

pub fn main() -> Nil {
  case argv.load().arguments {
    ["build"] ->
      case build.main() {
        Ok(Nil) -> io.println("Built the site into dist/.")
        Error(problem) -> {
          io.println_error(error.to_string(problem))
          halt(1)
        }
      }

    _ -> io.println("Usage: gleam run build")
  }
}

@external(erlang, "erlang", "halt")
fn halt(status: Int) -> Nil
