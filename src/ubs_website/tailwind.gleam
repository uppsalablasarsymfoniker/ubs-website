// IMPORTS ---------------------------------------------------------------------

import gleam/result
import tailwind
import ubs_website/error.{type Error}

// RUN -------------------------------------------------------------------------

/// Compile `input` to a minified stylesheet at `output`. The Tailwind version
/// is pinned in `gleam.toml` under `[tools.tailwind]`; glailglind downloads it
/// on first use.
///
pub fn run(input input: String, output output: String) -> Result(Nil, Error) {
  tailwind.install_and_run([
    "--input=" <> input,
    "--output=" <> output,
    "--minify",
  ])
  |> result.replace(Nil)
  |> result.map_error(error.StylesCouldNotBeBuilt)
}
