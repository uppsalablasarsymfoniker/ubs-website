import gleam/option.{None, Some}
import gleam/time/calendar
import simplifile
import ubs_website/data/entry
import ubs_website/error

const concert =
  "+++
title = \"Januarikalaset\"
summary = \"\"
performances = [2027-01-30T15:00:00.000, 2027-01-30T19:00:00]
+++

Med **Trio X**.
"

pub fn parse_reads_fields_and_body_test() {
  let assert Ok(concert) = entry.parse("concert.sv.md", concert)

  assert entry.string(concert, "title") == Ok("Januarikalaset")
  assert entry.body_to_html(concert) == "<p>Med <strong>Trio X</strong>.</p>\n"
}

pub fn parse_requires_front_matter_test() {
  assert entry.parse("page.sv.md", "# Rubrik")
    == Error(error.ContentMissingFrontMatter("page.sv.md"))
}

pub fn empty_string_counts_as_missing_test() {
  let assert Ok(concert) = entry.parse("concert.sv.md", concert)

  assert entry.optional_string(concert, "summary") == Ok(None)
  assert entry.string(concert, "summary")
    == Error(error.ContentMissingField("concert.sv.md", "summary"))
}

pub fn date_times_accept_cms_milliseconds_test() {
  let assert Ok(concert) = entry.parse("concert.sv.md", concert)
  let assert Ok([#(date, first), #(_, second)]) =
    entry.date_times(concert, "performances")

  assert date == calendar.Date(2027, calendar.January, 30)
  assert first.hours == 15
  assert second.hours == 19
}

pub fn tables_name_their_position_test() {
  let source = "+++\n+++\n"
  let assert Ok(empty) = entry.parse("members.toml", source)
  assert entry.tables(empty, "members") == Ok([])

  let assert Ok(cleared) =
    entry.parse("members.toml", "+++\nmembers = []\n+++\n")
  assert entry.tables(cleared, "members") == Ok([])

  let assert Ok(data) =
    entry.parse(
      "members.toml",
      "+++\n[[members]]\nname = \"A\"\n[[members]]\nsection = \"oboe\"\n+++\n",
    )
  let assert Ok([_, second]) = entry.tables(data, "members")
  assert entry.string(second, "name")
    == Error(error.ContentMissingField("members.toml (members #2)", "name"))
}

pub fn read_collection_pairs_translations_test() {
  let directory = "build/test-content/concerts"
  let _ = simplifile.delete(directory)
  let assert Ok(_) = simplifile.create_directory_all(directory)
  let assert Ok(_) = simplifile.write(directory <> "/a.sv.md", concert)
  let assert Ok(_) = simplifile.write(directory <> "/a.en.md", concert)
  let assert Ok(_) = simplifile.write(directory <> "/b.sv.md", concert)

  let assert Ok([a, b]) = entry.read_collection(directory)
  assert a.slug == "a"
  let assert Some(_) = a.english
  assert b.english == None

  let assert Ok(_) = simplifile.write(directory <> "/c.en.md", concert)
  assert entry.read_collection(directory)
    == Error(error.ContentMissingSwedish(directory <> "/c.en.md"))
}
