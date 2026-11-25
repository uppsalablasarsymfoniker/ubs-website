// IMPORTS ---------------------------------------------------------------------

import filepath
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/time/calendar.{type Date, type TimeOfDay}
import mork
import simplifile
import tom.{type Toml}
import ubs_website/data/language.{type Language}
import ubs_website/error.{type Error}

// TYPES -----------------------------------------------------------------------

/// One content file: TOML fields and, for Markdown files, a Markdown body.
/// Sveltia CMS writes Markdown entries with `format: toml-frontmatter`, which
/// puts the fields between two `+++` lines.
///
pub type Entry {
  Entry(path: String, fields: Dict(String, Toml), body: String)
}

/// The translatable part of an entry: what a page, concert, or news item says.
/// The body is HTML rendered from the entry's Markdown.
///
pub type Text {
  Text(title: String, summary: Option(String), body: String)
}

/// A Swedish entry and, when someone has translated it, its English version.
///
pub type Translations {
  Translations(slug: String, swedish: Entry, english: Option(Entry))
}

// CONSTRUCTORS ----------------------------------------------------------------

/// Read a Markdown file with TOML front matter.
///
pub fn read(path: String) -> Result(Entry, Error) {
  use source <- result.try(
    simplifile.read(path)
    |> result.map_error(error.ContentCouldNotBeRead(path, _)),
  )

  parse(path, source)
}

pub fn parse(path: String, source: String) -> Result(Entry, Error) {
  use #(front_matter, body) <- result.try(split(path, source))
  use fields <- result.try(
    tom.parse(front_matter)
    |> result.map_error(error.ContentInvalidFrontMatter(path, _)),
  )

  Ok(Entry(path:, fields:, body: string.trim(body)))
}

/// Read a plain TOML data file, such as the member list. The entry has no body.
///
pub fn read_data(path: String) -> Result(Entry, Error) {
  use source <- result.try(
    simplifile.read(path)
    |> result.map_error(error.ContentCouldNotBeRead(path, _)),
  )
  use fields <- result.try(
    tom.parse(source)
    |> result.map_error(error.ContentInvalidFrontMatter(path, _)),
  )

  Ok(Entry(path:, fields:, body: ""))
}

/// Read `<directory>/<name>.sv.md` and `<directory>/<name>.en.md`, both of
/// which must exist.
///
pub fn read_translated(
  directory: String,
  name: String,
) -> Result(language.Translated(Entry), Error) {
  use swedish <- result.try(read(path(directory, name, language.Swedish)))
  let english_path = path(directory, name, language.English)
  use english <- result.try(case simplifile.is_file(english_path) {
    Ok(True) -> read(english_path)
    Ok(False) | Error(_) -> Error(error.ContentMissingTranslation(english_path))
  })

  Ok(language.Translated(swedish:, english:))
}

/// Read every entry in a collection folder. Each entry needs a Swedish file;
/// the English one is optional.
///
pub fn read_collection(directory: String) -> Result(List(Translations), Error) {
  use files <- result.try(
    simplifile.read_directory(directory)
    |> result.map_error(error.ContentCouldNotBeListed(directory, _)),
  )
  let names = list.filter(files, string.ends_with(_, ".md"))
  let swedish = slugs(names, language.Swedish)
  let english = slugs(names, language.English)

  use _ <- result.try(
    list.try_each(english, fn(slug) {
      case list.contains(swedish, slug) {
        True -> Ok(Nil)
        False ->
          Error(
            error.ContentMissingSwedish(path(directory, slug, language.English)),
          )
      }
    }),
  )

  list.sort(swedish, string.compare)
  |> list.try_map(fn(slug) {
    use swedish <- result.try(read(path(directory, slug, language.Swedish)))
    use english <- result.try(case list.contains(english, slug) {
      True -> read(path(directory, slug, language.English)) |> result.map(Some)
      False -> Ok(None)
    })

    Ok(Translations(slug:, swedish:, english:))
  })
}

fn path(directory: String, name: String, language: Language) -> String {
  filepath.join(directory, name <> "." <> language.code(language) <> ".md")
}

fn slugs(files: List(String), language: Language) -> List(String) {
  let suffix = "." <> language.code(language) <> ".md"
  list.filter_map(files, fn(file) {
    case string.ends_with(file, suffix) {
      True -> Ok(string.drop_end(file, string.length(suffix)))
      False -> Error(Nil)
    }
  })
}

fn split(path: String, source: String) -> Result(#(String, String), Error) {
  case string.replace(source, "\r\n", "\n") {
    "+++\n+++" <> body -> Ok(#("", body))
    "+++\n" <> rest ->
      string.split_once(rest, "\n+++")
      |> result.replace_error(error.ContentMissingFrontMatter(path))
    _ -> Error(error.ContentMissingFrontMatter(path))
  }
}

// FIELDS ----------------------------------------------------------------------

/// A required text field. An empty string counts as missing, because the CMS
/// writes one when an editor clears a field.
///
pub fn string(entry: Entry, field: String) -> Result(String, Error) {
  use value <- result.try(optional_string(entry, field))
  option.to_result(value, error.ContentMissingField(entry.path, field))
}

pub fn optional_string(
  entry: Entry,
  field: String,
) -> Result(Option(String), Error) {
  case tom.get_string(entry.fields, [field]) {
    Ok(value) ->
      case string.trim(value) {
        "" -> Ok(None)
        value -> Ok(Some(value))
      }
    Error(tom.NotFound(_)) -> Ok(None)
    Error(tom.WrongType(..)) ->
      Error(error.ContentInvalidField(entry.path, field, "text"))
  }
}

/// A date, written either as a TOML date or as the date part of a date-time.
///
pub fn date(entry: Entry, field: String) -> Result(Date, Error) {
  case tom.get(entry.fields, [field]) {
    Ok(tom.Date(date)) | Ok(tom.DateTime(date:, ..)) -> Ok(date)
    Ok(_) -> Error(error.ContentInvalidField(entry.path, field, "a date"))
    Error(_) -> Error(error.ContentMissingField(entry.path, field))
  }
}

/// A non-empty list of local date-times, such as a concert's performances.
///
pub fn date_times(
  entry: Entry,
  field: String,
) -> Result(List(#(Date, TimeOfDay)), Error) {
  let invalid =
    error.ContentInvalidField(entry.path, field, "a list of dates with times")
  case tom.get(entry.fields, [field]) {
    Ok(tom.Array([])) | Error(_) ->
      Error(error.ContentMissingField(entry.path, field))
    Ok(tom.Array(values)) ->
      list.try_map(values, fn(value) {
        case value {
          tom.DateTime(date:, time:, ..) -> Ok(#(date, time))
          _ -> Error(invalid)
        }
      })
    Ok(_) -> Error(invalid)
  }
}

/// A list of tables, such as `[[members]]`, each read as its own entry. The
/// entries' paths name their position, so errors point at the right item.
///
pub fn tables(entry: Entry, field: String) -> Result(List(Entry), Error) {
  case tom.get(entry.fields, [field]) {
    Error(tom.NotFound(_)) | Ok(tom.Array([])) -> Ok([])
    Ok(tom.ArrayOfTables(tables)) ->
      Ok(
        list.index_map(tables, fn(fields, index) {
          let path =
            entry.path
            <> " ("
            <> field
            <> " #"
            <> int.to_string(index + 1)
            <> ")"
          Entry(path:, fields:, body: "")
        }),
      )
    Ok(_) | Error(_) ->
      Error(error.ContentInvalidField(entry.path, field, "a list of items"))
  }
}

/// The entry's title, optional summary, and body.
///
pub fn text(entry: Entry) -> Result(Text, Error) {
  use title <- result.try(string(entry, "title"))
  use summary <- result.try(optional_string(entry, "summary"))

  Ok(Text(title:, summary:, body: body_to_html(entry)))
}

/// The text of an optional translation.
///
pub fn optional_text(entry: Option(Entry)) -> Result(Option(Text), Error) {
  case entry {
    Some(entry) -> text(entry) |> result.map(Some)
    None -> Ok(None)
  }
}

// CONVERSIONS -----------------------------------------------------------------

/// The body rendered from Markdown to HTML.
///
pub fn body_to_html(entry: Entry) -> String {
  mork.configure()
  |> mork.tables(True)
  |> mork.parse_with_options(entry.body)
  |> mork.to_html
}
