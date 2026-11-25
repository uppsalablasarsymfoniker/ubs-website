// IMPORTS ---------------------------------------------------------------------

import gleam/int
import gleam/string
import gleam/time/calendar.{type Date, type TimeOfDay}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ubs_website/data/language.{type Language, English, Swedish}

// CONVERSIONS -----------------------------------------------------------------

/// "30 januari 2027" or "30 January 2027".
///
pub fn to_human_readable(date: Date, language: Language) -> String {
  int.to_string(date.day)
  <> " "
  <> month(date.month, language)
  <> " "
  <> int.to_string(date.year)
}

/// "19.00" in Swedish, "19:00" in English.
///
pub fn time_to_human_readable(time: TimeOfDay, language: Language) -> String {
  let separator = language.pick(language, swedish: ".", english: ":")
  pad(time.hours) <> separator <> pad(time.minutes)
}

pub fn to_iso8601(date: Date) -> String {
  int.to_string(date.year)
  <> "-"
  <> pad(calendar.month_to_int(date.month))
  <> "-"
  <> pad(date.day)
}

pub fn date_time_to_iso8601(date: Date, time: TimeOfDay) -> String {
  to_iso8601(date) <> "T" <> pad(time.hours) <> ":" <> pad(time.minutes)
}

fn month(month: calendar.Month, language: Language) -> String {
  case language {
    English -> calendar.month_to_string(month)
    Swedish ->
      case month {
        calendar.January -> "januari"
        calendar.February -> "februari"
        calendar.March -> "mars"
        calendar.April -> "april"
        calendar.May -> "maj"
        calendar.June -> "juni"
        calendar.July -> "juli"
        calendar.August -> "augusti"
        calendar.September -> "september"
        calendar.October -> "oktober"
        calendar.November -> "november"
        calendar.December -> "december"
      }
  }
}

fn pad(number: Int) -> String {
  string.pad_start(int.to_string(number), 2, "0")
}

// VIEW ------------------------------------------------------------------------

pub fn view(date: Date, language: Language) -> Element(a) {
  html.time([attribute.attribute("datetime", to_iso8601(date))], [
    html.text(to_human_readable(date, language)),
  ])
}

/// "30 januari 2027, 19.00".
///
pub fn date_time_view(
  date: Date,
  time: TimeOfDay,
  language: Language,
) -> Element(a) {
  html.time(
    [attribute.attribute("datetime", date_time_to_iso8601(date, time))],
    [
      html.text(
        to_human_readable(date, language)
        <> ", "
        <> time_to_human_readable(time, language),
      ),
    ],
  )
}
