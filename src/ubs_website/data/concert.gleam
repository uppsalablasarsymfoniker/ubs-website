// IMPORTS ---------------------------------------------------------------------

import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/result
import gleam/time/calendar.{type Date, type TimeOfDay}
import ubs_website/data/entry.{type Text}
import ubs_website/error.{type Error}

// TYPES -----------------------------------------------------------------------

/// A concert, with one or more performances. Dates, venue, tickets, and image
/// come from the Swedish file; the English translation only adds text.
///
pub type Concert {
  Concert(
    slug: String,
    performances: Performances,
    venue: String,
    ticket_url: Option(String),
    image: Option(String),
    swedish: Text,
    english: Option(Text),
  )
}

pub type Performance {
  Performance(date: Date, time: TimeOfDay)
}

/// A concert's performances in time order. Split into the first and the rest
/// so there is always at least one: a concert without a performance cannot be
/// constructed.
///
pub type Performances {
  Performances(first: Performance, rest: List(Performance))
}

pub type Status {
  Upcoming
  Past
}

// CONSTRUCTORS ----------------------------------------------------------------

pub fn load(directory: String) -> Result(List(Concert), Error) {
  use collection <- result.try(entry.read_collection(directory))
  use translations <- list.try_map(collection)
  let source = translations.swedish

  use performances <- result.try(entry.date_times(source, "performances"))
  use venue <- result.try(entry.string(source, "venue"))
  use ticket_url <- result.try(entry.optional_string(source, "ticket_url"))
  use image <- result.try(entry.optional_string(source, "image"))
  use swedish <- result.try(entry.text(source))
  use english <- result.try(entry.optional_text(translations.english))

  let sorted =
    performances
    |> list.map(fn(performance) { Performance(performance.0, performance.1) })
    |> list.sort(compare_performances)
  use performances <- result.try(case sorted {
    [first, ..rest] -> Ok(Performances(first:, rest:))
    [] -> Error(error.ContentMissingField(source.path, "performances"))
  })

  Ok(Concert(
    slug: translations.slug,
    performances:,
    venue:,
    ticket_url:,
    image:,
    swedish:,
    english:,
  ))
}

// QUERIES ---------------------------------------------------------------------

/// A concert stays upcoming through the day of its last performance.
///
pub fn status(concert: Concert, today: Date) -> Status {
  case calendar.naive_date_compare(last_performance(concert).date, today) {
    order.Lt -> Past
    order.Eq | order.Gt -> Upcoming
  }
}

/// Every performance, in time order.
///
pub fn performance_list(concert: Concert) -> List(Performance) {
  [concert.performances.first, ..concert.performances.rest]
}

pub fn last_performance(concert: Concert) -> Performance {
  list.last(concert.performances.rest)
  |> result.unwrap(concert.performances.first)
}

/// Upcoming concerts, soonest first.
///
pub fn upcoming(concerts: List(Concert), today: Date) -> List(Concert) {
  concerts
  |> list.filter(fn(concert) { status(concert, today) == Upcoming })
  |> list.sort(compare_first_performance)
}

/// Past concerts, most recent first.
///
pub fn past(concerts: List(Concert), today: Date) -> List(Concert) {
  concerts
  |> list.filter(fn(concert) { status(concert, today) == Past })
  |> list.sort(fn(a, b) { order.negate(compare_first_performance(a, b)) })
}

fn compare_first_performance(a: Concert, b: Concert) -> order.Order {
  compare_performances(a.performances.first, b.performances.first)
}

fn compare_performances(a: Performance, b: Performance) -> order.Order {
  use <- order.lazy_break_tie(calendar.naive_date_compare(a.date, b.date))
  order.break_tie(
    int.compare(a.time.hours, b.time.hours),
    int.compare(a.time.minutes, b.time.minutes),
  )
}
