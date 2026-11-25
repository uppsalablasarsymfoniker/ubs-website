// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/result
import gleam/time/calendar.{type Date}
import ubs_website/data/entry.{type Text}
import ubs_website/error.{type Error}

// TYPES -----------------------------------------------------------------------

/// A news item. The date and image come from the Swedish file; the English
/// translation only adds text.
///
pub type NewsItem {
  NewsItem(
    slug: String,
    date: Date,
    image: Option(String),
    swedish: Text,
    english: Option(Text),
  )
}

// CONSTRUCTORS ----------------------------------------------------------------

/// Every news item, newest first.
///
pub fn load(directory: String) -> Result(List(NewsItem), Error) {
  use collection <- result.try(entry.read_collection(directory))
  use items <- result.map(
    list.try_map(collection, fn(translations) {
      let source = translations.swedish
      use date <- result.try(entry.date(source, "date"))
      use image <- result.try(entry.optional_string(source, "image"))
      use swedish <- result.try(entry.text(source))
      use english <- result.try(entry.optional_text(translations.english))

      Ok(NewsItem(slug: translations.slug, date:, image:, swedish:, english:))
    }),
  )

  list.sort(items, fn(a, b) {
    order.negate(calendar.naive_date_compare(a.date, b.date))
  })
}
