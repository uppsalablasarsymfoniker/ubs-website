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
    performances: List(Performance),
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

  let performances =
    performances
    |> list.map(fn(performance) { Performance(performance.0, performance.1) })
    |> list.sort(compare_performances)

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
  case list.last(concert.performances) {
    Ok(last) ->
      case calendar.naive_date_compare(last.date, today) {
        order.Lt -> Past
        order.Eq | order.Gt -> Upcoming
      }
    Error(Nil) -> Past
  }
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
  case a.performances, b.performances {
    [a, ..], [b, ..] -> compare_performances(a, b)
    [], [] -> order.Eq
    [], _ -> order.Lt
    _, [] -> order.Gt
  }
}

fn compare_performances(a: Performance, b: Performance) -> order.Order {
  use <- order.lazy_break_tie(calendar.naive_date_compare(a.date, b.date))
  order.break_tie(
    int.compare(a.time.hours, b.time.hours),
    int.compare(a.time.minutes, b.time.minutes),
  )
}
