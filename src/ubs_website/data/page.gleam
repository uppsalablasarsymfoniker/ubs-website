// IMPORTS ---------------------------------------------------------------------

import gleam/result
import ubs_website/data/entry.{type Text}
import ubs_website/data/language.{type Translated, Translated}
import ubs_website/error.{type Error}

// TYPES -----------------------------------------------------------------------

/// The general pages. Each exists in both languages, as
/// `content/pages/<name>.sv.md` and `<name>.en.md`.
///
pub type Pages {
  Pages(
    home: Translated(Text),
    about: Translated(Text),
    join: Translated(Text),
    booking: Translated(Text),
    contact: Translated(Text),
  )
}

// CONSTRUCTORS ----------------------------------------------------------------

pub fn load(directory: String) -> Result(Pages, Error) {
  use home <- result.try(read(directory, "home"))
  use about <- result.try(read(directory, "about"))
  use join <- result.try(read(directory, "join"))
  use booking <- result.try(read(directory, "booking"))
  use contact <- result.try(read(directory, "contact"))

  Ok(Pages(home:, about:, join:, booking:, contact:))
}

fn read(directory: String, name: String) -> Result(Translated(Text), Error) {
  use entries <- result.try(entry.read_translated(directory, name))
  use swedish <- result.try(entry.text(entries.swedish))
  use english <- result.try(entry.text(entries.english))

  Ok(Translated(swedish:, english:))
}
