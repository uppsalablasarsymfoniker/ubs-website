// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/option.{type Option}
import gleam/result
import ubs_website/data/entry
import ubs_website/error.{type Error}

// TYPES -----------------------------------------------------------------------

pub type Member {
  Member(name: String, section: Section, role: Option(String))
}

pub type Section {
  Conductor
  Flute
  Oboe
  Bassoon
  Clarinet
  Saxophone
  Horn
  Trumpet
  Trombone
  Euphonium
  Tuba
  DoubleBass
  Percussion
}

// CONSTANTS -------------------------------------------------------------------

/// Sections in the order the member list shows them.
///
pub const sections = [
  Conductor,
  Flute,
  Oboe,
  Bassoon,
  Clarinet,
  Saxophone,
  Horn,
  Trumpet,
  Trombone,
  Euphonium,
  Tuba,
  DoubleBass,
  Percussion,
]

// CONSTRUCTORS ----------------------------------------------------------------

/// Read the `[[members]]` list from a TOML file. A file without members is an
/// empty list: members are only listed once they have agreed to it.
///
pub fn load(path: String) -> Result(List(Member), Error) {
  use data <- result.try(entry.read_data(path))
  use items <- result.try(entry.tables(data, "members"))
  use item <- list.try_map(items)
  use name <- result.try(entry.string(item, "name"))
  use key <- result.try(entry.string(item, "section"))
  use section <- result.try(
    section_from_key(key)
    |> result.replace_error(error.ContentUnknownSection(item.path, key)),
  )
  use role <- result.try(entry.optional_string(item, "role"))

  Ok(Member(name:, section:, role:))
}

// CONVERSIONS -----------------------------------------------------------------

/// The key stored in `members.toml` and offered by the CMS.
///
pub fn section_to_key(section: Section) -> String {
  case section {
    Conductor -> "conductor"
    Flute -> "flute"
    Oboe -> "oboe"
    Bassoon -> "bassoon"
    Clarinet -> "clarinet"
    Saxophone -> "saxophone"
    Horn -> "horn"
    Trumpet -> "trumpet"
    Trombone -> "trombone"
    Euphonium -> "euphonium"
    Tuba -> "tuba"
    DoubleBass -> "double_bass"
    Percussion -> "percussion"
  }
}

pub fn section_from_key(key: String) -> Result(Section, Nil) {
  list.find(sections, fn(section) { section_to_key(section) == key })
}
